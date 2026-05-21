---@type LazySpec
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			auto_integrations = true,
			-- Inherit the terminal's background so Ghostty's background-opacity
			-- shows through. Sets Normal (and most integration highlight groups)
			-- to bg=NONE.
			transparent_background = true,
		},
		init = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
