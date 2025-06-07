local M = {}

M.defaults = {
	overlay = {
		highlight = {
			fg = "#ffffff",
			bg = "#ff6b6b",
			bold = true,
		},
		border = "rounded",
		timeout = 5000, -- 5 seconds timeout
	},
	max_windows = 9, -- maximum number of windows to show
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M

