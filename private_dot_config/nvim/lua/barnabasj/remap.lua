local wk = require("which-key")
-- config
wk.add({
	{
		"<leader>rc",
		function()
			vim.cmd("source $MYVIMRC")
		end,
		desc = "[R]eload [c]onfig",
	},
})
-- netrw
wk.add({
	{ "<leader>f", group = "File" },
	{ "<leader>fe", vim.cmd.Ex, desc = "Open explorer" },
})

-- convenience
wk.add({
	{ "<ESC>", "<cmd>nohlsearch<CR>", desc = "clear hl search" },
})
