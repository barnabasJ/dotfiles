// KWin script: toggle visibility of the Ghostty drop-down window.
//
// Runs inside KWin itself (X11 and Wayland, Plasma 5 and 6), so it avoids
// the xdotool/wmctrl tree-walk race that killed our earlier attempts and
// it survives the Plasma 6 / Wayland upgrade unchanged (modulo the API
// shims below).
//
// Lifecycle:
//   - Ghostty is auto-started at session login (see autostart .desktop).
//   - When the dropdown window appears, we minimize it immediately so the
//     user sees the desktop, not a flash of terminal.
//   - Alt+T toggles minimized/restored. Restoring also raises and focuses.

const CLASS = "com.mitchellh.ghostty-dropdown";
const EXEC = "ghostty";
const ARGS = ["--class=" + CLASS, "--window-decoration=none"];

// When toggle() launches a new instance (because no window matched), set
// this flag so the windowAdded handler shows it instead of minimizing.
// Without the flag, the autostart-on-login path (where we DO want it
// minimized on appear) couldn't be distinguished from the on-demand path.
let launchedFromShortcut = false;

function launchGhostty() {
  // Ask the user systemd to (re)start our ghostty-dropdown.service. The
  // unit has Restart=always so this only matters if the service was masked
  // or hit too many restart failures; in the normal case ghostty is
  // already running and we never get here.
  //
  // Works on Plasma 5 + 6 and X11 + Wayland — KLauncher was removed in
  // Plasma 6, but the user systemd has been on the session bus for years.
  callDBus(
    "org.freedesktop.systemd1",
    "/org/freedesktop/systemd1",
    "org.freedesktop.systemd1.Manager",
    "StartUnit",
    "ghostty-dropdown.service",
    "replace",
  );
}

// Plasma 6 renamed workspace.clientList/activeClient/clientAdded to
// windowList/activeWindow/windowAdded. Feature-detect to stay portable.
function listWindows() {
  return typeof workspace.windowList === "function"
    ? workspace.windowList()
    : workspace.clientList();
}

function setActive(w) {
  if ("activeWindow" in workspace) {
    workspace.activeWindow = w;
  } else {
    workspace.activeClient = w;
  }
}

function windowAddedSignal() {
  return workspace.windowAdded || workspace.clientAdded;
}

function matchesDropdown(w) {
  return w && w.resourceClass && w.resourceClass.toString() === CLASS;
}

function findDropdown() {
  const list = listWindows();
  for (let i = 0; i < list.length; i++) {
    if (matchesDropdown(list[i])) return list[i];
  }
  return null;
}

// Resize the window to fill the maximize area of its current screen. The
// MaximizeArea is the area a maximized window would occupy — it excludes
// the top task bar / panels via the panel's _NET_WM_STRUT_PARTIAL, which
// is exactly the "fullscreen-but-leave-the-panel-visible" geometry we want.
function fillScreen(w) {
  const area = workspace.clientArea(KWin.MaximizeArea, w);
  w.frameGeometry = area;
}

function toggle() {
  const win = findDropdown();
  if (!win) {
    // First-press-after-kill or before-autostart-fired: spawn Ghostty.
    // The windowAdded handler will fill the screen and focus it (the flag
    // tells it not to start minimized).
    launchedFromShortcut = true;
    launchGhostty();
    return;
  }

  if (win.minimized) {
    win.minimized = false;
    // Re-apply geometry on every restore — KWin remembers the pre-minimize
    // size, but the user may have moved monitors / changed panel height in
    // the meantime, and we always want the dropdown filling the current
    // screen.
    fillScreen(win);
    setActive(win);
  } else {
    win.minimized = true;
  }
}

// Configure new dropdown windows as they appear:
//   - Always fill the screen (excluding the panel).
//   - If we were the ones who launched it via Alt+T, raise + focus it.
//   - Otherwise (autostart at login), minimize it so login isn't loud.
windowAddedSignal().connect(function (w) {
  if (!matchesDropdown(w)) return;
  fillScreen(w);
  if (launchedFromShortcut) {
    launchedFromShortcut = false;
    setActive(w);
  } else {
    w.minimized = true;
  }
});

registerShortcut(
  "ghostty-dropdown-toggle",
  "Toggle Ghostty Dropdown",
  "Alt+T",
  toggle,
);
