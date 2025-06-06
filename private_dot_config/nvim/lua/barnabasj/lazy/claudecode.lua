return {
	"coder/claudecode.nvim",
	config = function()
		require("claudecode").setup({
			-- Optional configuration options
			-- log_level = "debug", -- Uncomment for debugging
		})
	end,
	keys = {
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude Code" },
		{ "<leader>ast", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude Code Status" },
	},
}