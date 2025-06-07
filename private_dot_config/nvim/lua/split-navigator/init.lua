local config = require("split-navigator.config")
local utils = require("split-navigator.utils")

local M = {}

local overlay_wins = {}
local timer = nil

local function clear_overlays()
	for _, win in ipairs(overlay_wins) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	overlay_wins = {}

	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end
end

local function create_overlay(win, number)
	local opts = config.options
	local content = string.format(" %d ", number)

	local buf = utils.create_overlay_buffer(content)
	local overlay_config = utils.create_overlay_config(win, content, opts.overlay.border)

	local overlay_win = vim.api.nvim_open_win(buf, false, overlay_config)

	local highlight_name = "SplitNavigatorOverlay"
	vim.api.nvim_set_hl(0, highlight_name, opts.overlay.highlight)
	utils.apply_highlight(overlay_win, highlight_name)

	table.insert(overlay_wins, overlay_win)
	return overlay_win
end

local function setup_timeout()
	local opts = config.options
	if opts.overlay.timeout > 0 then
		timer = vim.loop.new_timer()
		timer:start(
			opts.overlay.timeout,
			0,
			vim.schedule_wrap(function()
				clear_overlays()
			end)
		)
	end
end

function M.show()
	clear_overlays()

	local wins = utils.get_visible_windows()

	if #wins <= 1 then
		vim.notify("Only one window open", vim.log.levels.INFO)
		return
	end

	local max_windows = math.min(#wins, config.options.max_windows)
	local win_to_number = {}

	for i = 1, max_windows do
		create_overlay(wins[i], i)
		win_to_number[tostring(i)] = wins[i]
	end

	setup_timeout()
	vim.cmd("redraw")

	local char = vim.fn.getchar()
	local key = vim.fn.nr2char(char)

	clear_overlays()

	if utils.is_valid_window_number(key, max_windows) and win_to_number[key] then
		vim.api.nvim_set_current_win(win_to_number[key])
	elseif key ~= "\27" and key ~= "" then -- Not ESC or timeout
		vim.notify("Invalid window number: " .. key, vim.log.levels.WARN)
	end
end

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("SplitNavigator", function()
		M.show()
	end, {
		desc = "Show numbered overlays on splits for navigation",
	})
end

return M

