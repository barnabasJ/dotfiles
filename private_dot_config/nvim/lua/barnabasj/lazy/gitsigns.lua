-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"folke/which-key.nvim",
		},
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
		},
	},
}
