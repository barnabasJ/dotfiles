return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local codecompanion_status = require("barnabasj.codecompanion_status")
		local pomodoro = require("pomodoro")

		require("lualine").setup({
			options = {
				refresh = {
					statusline = 100,
				},
			},
			sections = {
				lualine_x = {
					codecompanion_status,
					pomodoro.get_pomodoro_status,
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
	end,
}