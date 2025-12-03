---@type LazySpec
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			auto_integrations = true,
		},
		init = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
