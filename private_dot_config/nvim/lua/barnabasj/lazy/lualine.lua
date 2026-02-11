---@type LazySpec
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", { "catppuccin/nvim", name = "catppuccin" } },
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
				-- match the rounded theme from catppuccin/tmux
				-- section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
				-- component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
				refresh = {
					statusline = 100,
				},
			},
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
	end,
}
