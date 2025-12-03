---@type LazySpec
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", { "catppuccin/nvim", name = "catppuccin" } },
	config = function()
		local codecompanion_status = require("barnabasj.codecompanion_status")

		require("lualine").setup({
			options = {
				theme = "catppuccin",
				section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
				component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
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
					codecompanion_status,
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
	end,
}
