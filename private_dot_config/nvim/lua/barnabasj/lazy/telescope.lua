-- requires ripgrep and fzf to be installed
return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",

	tag = "0.1.8",

	dependencies = {
		"nvim-lua/plenary.nvim",
		-- needed to register the keybindings
		"folke/which-key.nvim",
		-- better integration with neovim
		-- allows neovim to populate the telescope picker
		"nvim-telescope/telescope-ui-select.nvim",
		-- Useful for getting pretty icons, but requires a Nerd Font.
		{ -- If encountering errors, see telescope-fzf-native README for installation instructions
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},

	config = function()
		-- Telescope is a fuzzy finder that comes with a lot of different things that
		-- it can fuzzy find! It's more than just a "file finder", it can search
		-- many different aspects of Neovim, your workspace, LSP, and more!
		--
		-- The easiest way to use Telescope, is to start by doing something like:
		--  :Telescope help_tags
		--
		-- After running this command, a window will open up and you're able to
		-- type in the prompt window. You'll see a list of `help_tags` options and
		-- a corresponding preview of the help.
		--
		-- Two important keymaps to use while in Telescope are:
		--  - Insert mode: <c-/>
		--  - Normal mode: ?
		--
		-- This opens a window that shows you all of the keymaps for the current
		-- Telescope picker. This is really useful to discover what Telescope can
		-- do as well as how to actually do it!

		-- [[ Configure Telescope ]]
		-- See `:help telescope` and `:help telescope.setup()`
		require("telescope").setup({
			-- You can put your default mappings / updates / etc. in here
			--  All the info you're looking for is in `:help telescope.setup()`
			--
			-- defaults = {
			--   mappings = {
			--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
			--   },
			-- },
			-- pickers = {}
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })

		require("which-key").add({
			{ "<C-p>", builtin.git_files },
			{ "<leader>sh", builtin.help_tags, desc = "[S]earch [H]elp" },
			{ "<leader>sk", builtin.keymaps, desc = "[S]earch [K]eymaps" },
			{ "<leader>sf", builtin.find_files, desc = "[S]earch [F]iles" },
			{ "<leader>ss", builtin.builtin, desc = "[S]earch [S]elect Telescope" },
			{ "<leader>sw", builtin.grep_string, desc = "[S]earch current [W]ord" },
			{ "<leader>sg", builtin.live_grep, desc = "[S]earch by [G]rep" },
			{ "<leader>sd", builtin.diagnostics, desc = "[S]earch [D]iagnostics" },
			{ "<leader>sr", builtin.resume, desc = "[S]earch [R]esume" },
			{ "<leader>s.", builtin.oldfiles, desc = '[S]earch Recent Files ("." for repeat)' },
			{ "<leader>s<leader>", builtin.buffers, desc = "[ ] Find existing buffers" },
			{
				-- Slightly advanced example of overriding default behavior and theme
				"<leader>/",
				function()
					-- TODO check why the preview is not showing all the matches
					-- You can pass additional configuration to Telescope to change the theme, layout, etc.
					builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = true,
					}))
				end,
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				-- It's also possible to pass additional configuration options.
				--  See `:help telescope.builtin.live_grep()` for information about particular keys
				"<leader>s/",
				function()
					builtin.live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				desc = "[S]earch [/] in Open Files",
			},
		})
	end,
}
