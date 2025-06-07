local M = {}

function M.get_visible_windows()
	return vim.tbl_filter(function(win)
		local config = vim.api.nvim_win_get_config(win)
		return config.relative == ""
	end, vim.api.nvim_list_wins())
end

function M.get_window_center(win)
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)
	return {
		row = math.floor(height / 2),
		col = math.floor(width / 2),
	}
end

function M.create_overlay_buffer(content)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { content })
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	return buf
end

function M.create_overlay_config(win, content, border)
	local center = M.get_window_center(win)
	local overlay_width = #content
	local overlay_height = 1

	return {
		relative = "win",
		win = win,
		width = overlay_width,
		height = overlay_height,
		row = center.row,
		col = center.col - math.floor(overlay_width / 2),
		style = "minimal",
		border = border,
		focusable = false,
		zindex = 1000,
	}
end

function M.apply_highlight(win, highlight_name)
	local winhl = string.format("Normal:%s,FloatBorder:%s", highlight_name, highlight_name)
	vim.api.nvim_win_set_option(win, "winhl", winhl)
end

function M.is_valid_window_number(key, max_num)
	local num = tonumber(key)
	return num and num >= 1 and num <= max_num
end

return M

