#!/usr/bin/env bats

setup() {
  load '/usr/local/lib/bats-support/load'
  load '/usr/local/lib/bats-assert/load'
  load '/usr/local/lib/bats-file/load'
}

# --- Shell config files ---

@test ".bashrc exists" {
  assert_file_exists "$HOME/.bashrc"
}

@test ".aliases exists" {
  assert_file_exists "$HOME/.aliases"
}

@test ".bash_completion exists" {
  assert_file_exists "$HOME/.bash_completion"
}

# --- Dotfiles ---

@test ".tmux.conf exists" {
  assert_file_exists "$HOME/.tmux.conf"
}

@test ".prettierrc.json exists" {
  assert_file_exists "$HOME/.prettierrc.json"
}

@test ".taskrc exists" {
  assert_file_exists "$HOME/.taskrc"
}

@test ".vale.ini exists" {
  assert_file_exists "$HOME/.vale.ini"
}

# --- Config files ---

@test "starship.toml exists" {
  assert_file_exists "$HOME/.config/starship.toml"
}

@test "nvim init.lua exists" {
  assert_file_exists "$HOME/.config/nvim/init.lua"
}

@test "fastfetch config exists" {
  assert_file_exists "$HOME/.config/fastfetch/config.jsonc"
}

# --- Linux-specific files ---

@test "systemd ssh-agent service exists" {
  assert_file_exists "$HOME/.config/systemd/user/ssh-agent.service"
}

@test "ssh-agent service has correct content" {
  run cat "$HOME/.config/systemd/user/ssh-agent.service"
  assert_output --partial "ssh-agent"
  assert_output --partial "WantedBy=default.target"
}

# --- Ghostty drop-down terminal ---

@test "ghostty config exists" {
  assert_file_exists "$HOME/.config/ghostty/config"
}

@test "ghostty config sets Catppuccin Mocha theme" {
  run cat "$HOME/.config/ghostty/config"
  assert_output --partial "theme = Catppuccin Mocha"
}

@test "ghostty-dropdown systemd service exists" {
  assert_file_exists "$HOME/.config/systemd/user/ghostty-dropdown.service"
}

@test "ghostty-dropdown service is configured to restart" {
  run cat "$HOME/.config/systemd/user/ghostty-dropdown.service"
  assert_output --partial "Restart=always"
  assert_output --partial "ghostty-dropdown"
}

@test "KWin script main.js exists" {
  assert_file_exists "$HOME/.local/share/kwin/scripts/ghostty-dropdown/contents/code/main.js"
}

@test "KWin script metadata.json exists" {
  assert_file_exists "$HOME/.local/share/kwin/scripts/ghostty-dropdown/metadata.json"
}

@test "KWin script registers Alt+T shortcut" {
  run cat "$HOME/.local/share/kwin/scripts/ghostty-dropdown/contents/code/main.js"
  assert_output --partial "registerShortcut"
  assert_output --partial "Alt+T"
}

# --- nvim markdown rendering ---

@test "render-markdown.nvim plugin file exists" {
  assert_file_exists "$HOME/.config/nvim/lua/barnabasj/lazy/render-markdown.lua"
}

@test "image.nvim plugin file exists" {
  assert_file_exists "$HOME/.config/nvim/lua/barnabasj/lazy/image.lua"
}

@test "diagram.nvim plugin file exists" {
  assert_file_exists "$HOME/.config/nvim/lua/barnabasj/lazy/diagram.lua"
}

@test "diagram.nvim passes scale via cli_args to mmdc" {
  run cat "$HOME/.config/nvim/lua/barnabasj/lazy/diagram.lua"
  assert_output --partial 'cli_args'
  assert_output --partial '"-s"'
}

@test "environment.d ssh_auth_socket.conf exists" {
  assert_file_exists "$HOME/.config/environment.d/ssh_auth_socket.conf"
}

@test "environment.d ssh_askpass.conf exists" {
  assert_file_exists "$HOME/.config/environment.d/ssh_askpass.conf"
}

# --- Default package files ---

@test ".default-npm-packages exists" {
  assert_file_exists "$HOME/.default-npm-packages"
}

@test ".default-python-packages exists" {
  assert_file_exists "$HOME/.default-python-packages"
}

@test ".default-golang-pkgs exists" {
  assert_file_exists "$HOME/.default-golang-pkgs"
}

# --- Directories ---

@test "tmux plugin manager is installed" {
  assert_dir_exists "$HOME/.tmux/plugins/tpm"
}

@test "mise data directory exists" {
  assert_dir_exists "$HOME/.local/share/mise"
}

@test "mise binary exists and is executable" {
  assert_file_executable "$HOME/.local/bin/mise"
}

@test "asdf binary is not installed" {
  assert_file_not_exists "$HOME/.local/bin/asdf"
}

@test "asdf data directory is not present" {
  assert_dir_not_exists "$HOME/.asdf"
}

# --- Template rendering (Linux should NOT have macOS files) ---

@test ".zshrc should not exist on Linux" {
  assert_file_not_exists "$HOME/.zshrc"
}

@test ".zprofile should not exist on Linux" {
  assert_file_not_exists "$HOME/.zprofile"
}
