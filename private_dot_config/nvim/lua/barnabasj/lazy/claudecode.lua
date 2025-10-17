---@type LazySpec
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	opts = {
		terminal = {
			provider = "snacks",
			snacks_win_opts = {
				start_insert = true,
				auto_insert = false,
				auto_close = true,
			},
		},
	},
	keys = {
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude Code" },
		{ "<leader>ast", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude Code Status" },
	},
}
