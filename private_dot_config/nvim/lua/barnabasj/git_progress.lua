-- Feedback, and timings, for the git maps.
--
-- The stack and graph maps spend their time in git: a batch of processes to
-- resolve the stack, a checkout, then diffview rebuilding a view. All of it runs
-- from a keypress, so the editor sits still for as long as it takes and there is
-- nothing on screen to say whether it is working or wedged. That is what this
-- module is for.
--
-- Every blocking git call in `git_util` waits through `M.wait`, which is what
-- makes a spinner possible at all: `vim.wait` keeps the event loop turning while
-- the process runs, so a frame can be redrawn between polls. Nothing is drawn
-- for the first SHOW_AFTER_MS, so the maps that are already quick stay silent
-- rather than flashing a spinner at every keypress.
--
-- The same bookkeeping doubles as a profiler. Each phase records its wall time
-- and how many git processes it spawned, and `<leader>g?` prints the last run's
-- breakdown -- which is how you tell "git is slow in this repo" apart from "this
-- map is doing too much work".

local M = {}

local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

--- How long a frame stays up. Slow enough not to spend the run redrawing,
--- fast enough to read as motion.
local FRAME_MS = 80

--- Don't draw anything before this. Under it the operation is over before a
--- spinner would have said anything useful.
local SHOW_AFTER_MS = 150

--- Over this, leave the timing on the command line when the run finishes
--- instead of clearing it, so a slow run says so without being asked.
local SUMMARY_AFTER_MS = 1000

--- Ceiling on a single wait. Matches what `vim.system():wait()` would have used.
local WAIT_TIMEOUT_MS = 120000

--- Git processes spawned, ever. Phases record the counter at their edges and
--- subtract, so nothing has to be threaded through the call stack.
M.calls = 0

---@type table|nil # the run in flight, if any
local current = nil

---@type table|nil # the run that finished most recently, for M.report
M.last = nil

local function now()
	return vim.uv.hrtime() / 1e6
end

--- Everything here goes on the command line, and a line that does not fit earns
--- a hit-enter prompt -- which would leave a slow map waiting on a keypress it
--- never asked for. So nothing is ever allowed to be too long. `used` is the
--- width already spent on the chunks before this one.
local function fits(text, used)
	local room = math.max(vim.o.columns - (used or 0) - 1, 10)
	if vim.fn.strdisplaywidth(text) <= room then
		return text
	end
	return vim.fn.strcharpart(text, 0, room - 1) .. "…"
end

local function ms(n)
	return n >= 1000 and ("%.1fs"):format(n / 1000) or ("%dms"):format(math.floor(n + 0.5))
end

local Run = {}
Run.__index = Run

function Run:_draw()
	self.shown = true
	self.frame = (self.frame or 0) + 1
	local spinner = SPINNER[(self.frame - 1) % #SPINNER + 1] .. " "
	local label = self.title .. ": " .. (self.open and self.open.label or "working") .. "…"
	vim.api.nvim_echo({
		{ spinner, "DiagnosticInfo" },
		{ fits(label, vim.fn.strdisplaywidth(spinner)), "MoreMsg" },
	}, false, {})
	vim.cmd("redraw")
end

function Run:_close()
	if self.open then
		self.open.ms = now() - self.open.t0
		self.open.calls = M.calls - self.open.calls0
		self.open = nil
	end
end

--- Name what the run is doing from here on. Phases are what the profile is
--- broken down by, so they mark the boundaries worth measuring separately.
---
--- `blocking` is for the phases that hold the main loop without ever waiting on
--- a git process -- diffview rebuilding a view, mostly. Nothing will tick during
--- one, so the label is painted on the way in or it is never seen at all.
---@param label string
---@param blocking? boolean
function Run:phase(label, blocking)
	self:_close()
	self.open = { label = label, t0 = now(), calls0 = M.calls }
	self.phases[#self.phases + 1] = self.open
	if blocking or self.shown then
		self:_draw()
	end
end

--- Draw a frame, once the run has gone on long enough to be worth reporting.
function Run:tick()
	if self.shown or now() - self.t0 >= SHOW_AFTER_MS then
		self:_draw()
	end
end

function Run:_finish()
	self:_close()
	self.ms = now() - self.t0
	self.calls = M.calls - self.calls0
	if not self.shown then
		return
	end
	if self.ms >= SUMMARY_AFTER_MS then
		-- Slow enough that where the time went is worth saying unprompted. The
		-- full breakdown is a `<leader>g?` away.
		local parts = {}
		for _, p in ipairs(self.phases) do
			parts[#parts + 1] = ("%s %s"):format(p.label, ms(p.ms or 0))
		end
		local total = self.title .. " " .. ms(self.ms)
		vim.api.nvim_echo({
			{ total, "MoreMsg" },
			{ fits("  " .. table.concat(parts, " · "), vim.fn.strdisplaywidth(total)), "Comment" },
		}, false, {})
	else
		vim.api.nvim_echo({ { "" } }, false, {})
	end
end

--- Run `fn` as one reported operation. Nested calls join the run already in
--- flight rather than starting a second one, so a map that calls another map's
--- helper still reports as a single timeline.
---@generic T
---@param title string
---@param fn fun(run: table): T
---@return T
function M.run(title, fn)
	if current then
		return fn(current)
	end
	local run = setmetatable({ title = title, t0 = now(), calls0 = M.calls, phases = {} }, Run)
	current = run
	-- One return value, which is all any caller here has: `pcall` would need
	-- `table.pack` to carry more, and this LuaJIT has none.
	local ok, ret = pcall(fn, run)
	run:_finish()
	current, M.last = nil, run
	if not ok then
		error(ret, 0)
	end
	return ret
end

--- Count a git process against the phase in flight. Called by `git_util`, which
--- is the only place processes are spawned.
function M.count()
	M.calls = M.calls + 1
end

--- Wait for `cond`, animating the run in flight while it is pending.
---
--- The waiting itself is `vim.wait`, exactly as `vim.system():wait()` does it;
--- the only difference is that it comes back every frame so the spinner can be
--- redrawn. In a fast event context neither the redraw nor a non-fast wait is
--- allowed, so there it degrades to the plain blocking wait.
---@param cond fun(): boolean
---@param timeout? integer
function M.wait(cond, timeout)
	timeout = timeout or WAIT_TIMEOUT_MS
	if not current or vim.in_fast_event() then
		vim.wait(timeout, cond, 10, true)
		return
	end

	local deadline = now() + timeout
	while not cond() do
		local left = deadline - now()
		if left <= 0 then
			break
		end
		current:tick()
		local ok, code = vim.wait(math.floor(math.min(FRAME_MS, left)), cond, 10)
		if ok then
			break
		elseif code == -2 then
			-- <C-c>. Stop animating, but see the call through: abandoning a git
			-- process mid-flight would hand the caller a half-filled batch to make
			-- decisions from.
			vim.wait(math.floor(math.max(deadline - now(), 0)), cond, 10, true)
			break
		end
	end
end

--- Where the time went in the last run.
function M.report()
	local run = M.last
	if not run then
		vim.notify("git: nothing has been timed yet", vim.log.levels.INFO)
		return
	end
	local lines = { ("%s — %s, %d git processes"):format(run.title, ms(run.ms or 0), run.calls or 0) }
	for _, p in ipairs(run.phases) do
		lines[#lines + 1] = ("  %-26s %8s  %4d git"):format(p.label, ms(p.ms or 0), p.calls or 0)
	end
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "git timings" })
end

return M
