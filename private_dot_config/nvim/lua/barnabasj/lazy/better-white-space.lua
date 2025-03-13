return {
	-- https://github.com/ntpeters/vim-better-whitespace
	-- Highlights trailing whitespace
	"ntpeters/vim-better-whitespace",
	event = "BufReadPre",
	init = function()
		-- Disable for dashboard
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dashboard",
			callback = function()
				vim.b.better_whitespace_enabled = 0
			end,
		})
	end,
}
