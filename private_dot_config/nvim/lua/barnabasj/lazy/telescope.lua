-- requires ripgrep and fzf to be installed
return {
	"nvim-telescope/telescope.nvim",

	tag = "0.1.5",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("telescope").setup({})

		local builtin = require("telescope.builtin")

		local wk = require("which-key")

		wk.register({
			t = {
				name = "Telescope",
				f = { builtin.find_files, "file" },
				g = { builtin.git_files, "git file" },
				w = { builtin.grep_string, "word" },
				s = {
					function()
						builtin.grep_string({ search = vim.fn.input("Grep for > ") })
					end,
					"search",
				},
				l = { builtin.live_grep, "word live" },
				t = {
					names = "Tags",
					h = { builtin.help_tags, "help" },
				},
				r = { builtin.resume, "resume" },
				o = { builtin.oldfiles, "opened files" },
			},
		}, { prefix = "<leader>" })

		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
	end,
}
