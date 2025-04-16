-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"folke/which-key.nvim",
		},
		init = function()
			require("gitsigns").setup({
				current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
					delay = 300,
					ignore_whitespace = false,
					virt_text_priority = 100,
					use_focus = true,
				},
			})
		end,
		keys = {
			-- Navigation
			{
				"]c",
				function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						require("gitsigns").nav_hunk("next")
					end
				end,
				desc = "Jump to next git [c]hange",
			},
			{
				"[c",
				function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						require("gitsigns").nav_hunk("prev")
					end
				end,
				desc = "Jump to previous git [c]hange",
			},
			-- Toggles
			{
				"<leader>tb",
				function()
					require("gitsigns").toggle_current_line_blame()
				end,
				desc = "[T]oggle git show [b]lame line",
			},
			{
				"<leader>bl",
				function()
					require("gitsigns").blame()
				end,
				desc = "git [b]lame",
			},
		},
	},
}
