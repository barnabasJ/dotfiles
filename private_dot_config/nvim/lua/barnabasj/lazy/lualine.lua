---@type LazySpec
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", { "catppuccin/nvim", name = "catppuccin" } },
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
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
					{
						function()
							return " "
						end,
						color = function()
							local status = require("sidekick.status").get()
							if status then
								return status.kind == "Error" and "DiagnosticError"
									or status.busy and "DiagnosticWarn"
									or "Special"
							end
						end,
						cond = function()
							return require("sidekick.status").get() ~= nil
						end,
					},
				},
				lualine_x = {
					{
						function()
							local status = require("sidekick.status").cli()
							return " " .. (#status > 1 and #status or "")
						end,
						cond = function()
							return #require("sidekick.status").cli() > 0
						end,
						color = function()
							return "Special"
						end,
					},
					"encoding",
					"fileformat",
					"filetype",
				},
			},
		})
	end,
}
