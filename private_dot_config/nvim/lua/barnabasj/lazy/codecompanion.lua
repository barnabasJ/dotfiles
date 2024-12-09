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
		adapters = {
			codellama = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = {
						model = {
							default = "codellama:latest",
						},
					},
				})
			end,
			qwen14b = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = {
						model = {
							default = "qwen2.5-coder:14b",
						},
					},
				})
			end,
		},
		strategies = {
			--NOTE: Change the adapter as required
			chat = {
				adapter = "qwen14b",
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
