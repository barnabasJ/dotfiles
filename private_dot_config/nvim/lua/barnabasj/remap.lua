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

-- file explorer
wk.add({
	{ "<leader>f", group = "File" },
	{
		"<leader>fe",
		function()
			local current_file = vim.api.nvim_buf_get_name(0)
			local current_dir = vim.fn.fnamemodify(current_file, ":h")
			require("mini.files").open(current_dir)
		end,
		desc = "Open explorer",
	},
	{
		"<leader>fp",
		function()
			require("mini.files").open()
		end,
		desc = "Open explorer",
	},
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
	{ "<leader>y", '"+y', desc = "yank to clipboard", mode = "v" },
	{ "<leader>p", '"_dP', desc = "paste from clipboard", mode = "v" },
})

-- terminal
wk.add({
	mode = { "t" },
	{ "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit terminal mode" },
	{ "<C-q>", "<C-\\><C-n>", desc = "Exit terminal mode (Claude safe)" },
})

local quicker = require("quicker")
-- window navigation
wk.add({
	{ "<leader>w", group = "Window" },
	{
		"<leader>wn",
		function()
			require("split-navigator").show()
		end,
		desc = "Navigate to numbered split",
	},
})

-- quickfix
wk.add({
	{ "<leader>q", group = "Quickfix" },
	{
		"<leader>qo",
		function()
			quicker.open()
		end,
		desc = "Open quickfix",
	},
	{
		"<leader>qc",
		function()
			quicker.close()
		end,
		desc = "Close quickfix",
	},
	{
		"<leader>qe",
		function()
			quicker.expand({
				add_to_existing = true,
			})
		end,
		desc = "Expand context",
	},
	{
		"<leader>qcc",
		function()
			quicker.collapse()
		end,
		desc = "Collapse context",
	},
	{ "<leader>qn", ":cnext<CR>", desc = "Next quickfix" },
	{ "<leader>qp", ":cprev<CR>", desc = "Previous quickfix" },
	{ "<leader>ql", ":lnext<CR>", desc = "Next location" },
	{ "<leader>qh", ":lprev<CR>", desc = "Previous location" },
})

-- testing
wk.add({
	{ "<leader>t", group = "Test" },
	{
		"<leader>Tt",
		function()
			require("plenary.test_harness").test_directory(vim.fn.getcwd() .. "/tests")
		end,
		desc = "Run all tests",
	},
	{
		"<leader>Tf",
		function()
			local current_file = vim.api.nvim_buf_get_name(0)
			if current_file:match("_spec%.lua$") then
				require("plenary.test_harness").test_file(current_file)
			else
				vim.notify("Current file is not a test file (_spec.lua)", vim.log.levels.WARN)
			end
		end,
		desc = "Run current test file",
	},
})
