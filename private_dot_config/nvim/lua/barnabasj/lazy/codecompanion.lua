return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{ "nvim-lua/plenary.nvim" },
		{ "hrsh7th/nvim-cmp" },
		{ "stevearc/dressing.nvim", opts = {} },
		{ "nvim-telescope/telescope.nvim" },
	},
	opts = {
		--Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		display = {
			diff = {
				provider = "mini_diff",
			},
		},
		adapters = {
			ollama = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = {
						model = {
							default = "codellama:latest",
						},
					},
				})
			end,
		},
		strategies = {
			--NOTE: Change the adapter as required
			chat = {
				adapter = "ollama",
			},
			inline = {
				adapter = "copilot",
			},
		},
		opts = {
			log_level = "DEBUG",
		},
	},
}
