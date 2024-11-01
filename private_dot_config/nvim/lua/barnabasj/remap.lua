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
	{ "<leader>fe", ":lua MiniFiles.open()<CR>", desc = "Open explorer" },
})

-- tabs
wk.add({
	{ "<leader>tn", vim.cmd.tabnew, desc = "New tab" },
	{ "<leader>tc", vim.cmd.tabclose, desc = "Close tab" },
	{ "<leader>to", vim.cmd.tabonly, desc = "Close other tabs" },
	{ "<leader>tl", vim.cmd.tabnext, desc = "Next tab" },
	{ "<leader>th", vim.cmd.tabprevious, desc = "Previous tab" },
	{ "<leader>tm", vim.cmd.tabmove, desc = "Move tab" },
})

-- search
wk.add({
	mode = { "v" },
	{ "<leader>*", '"vy/<C-R>v<CR>', desc = "Search visually selected text ↓" },
	{ "<leader>#", '"vy?<C-R>v<CR>', desc = "Search visually selected text ↑" },
})

wk.add({
	{
		"<leader>*",
		':let @/ =  expand("<cword>")<CR>', -- @/ is the search register
		desc = "Sets the current word into the search register",
	},
})

-- convenience
wk.add({
	{ "<ESC>", "<cmd>nohlsearch<CR>", desc = "clear hl search" },
})
