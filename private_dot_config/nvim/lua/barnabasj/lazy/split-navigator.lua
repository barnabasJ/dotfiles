return {
	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},
	{
		dir = vim.fn.stdpath("config") .. "/lua/split-navigator",
		name = "split-navigator",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("split-navigator").setup({
				overlay = {
					highlight = {
						fg = "#ffffff",
						bg = "#ff6b6b",
						bold = true,
					},
					border = "rounded",
					timeout = 5000,
				},
				max_windows = 9,
			})
		end,
	},
}