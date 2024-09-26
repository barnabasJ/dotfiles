return {
	-- {
	-- 	-- https://github.com/folke/tokyonight.nvim
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {
	-- 		-- your configuration comes here
	-- 		-- or leave it empty to use the default settings
	-- 		terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	-- 		styles = {
	-- 			-- Style to be applied to different syntax groups
	-- 			-- Value is any valid attr-list value for `:help nvim_set_hl`
	-- 			comments = { italic = false },
	-- 			keywords = { italic = false },
	-- 			-- Background styles. Can be "dark", "transparent" or "normal"
	-- 			sidebars = "dark", -- style for sidebars, see below
	-- 			floats = "dark", -- style for floating windows
	-- 		},
	-- 	},
	-- 	init = function()
	-- 		vim.cmd.colorscheme("tokyonight-night")
	-- 	end,
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
