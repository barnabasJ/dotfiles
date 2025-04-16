return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local codecompanion_status = require("barnabasj.codecompanion_status")

		require("lualine").setup({
			options = {
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
