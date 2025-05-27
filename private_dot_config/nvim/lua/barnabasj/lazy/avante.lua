---@type LazySpec
return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
	opts = {
		providers = {
			ollama = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "http://127.0.0.1:11434/v1",
				model = "qwen2.5-coder:14b",
			},
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-3-5-sonnet-20241022",
				extra_request_body = {
					temperature = 0,
					max_tokens = 4096,
				},
			},
		},
		mappings = {
			diff = {
				ours = "so",
				theirs = "st",
				all_theirs = "sa",
				both = "sb",
				cursor = "sc",
				next = "]x",
				prev = "[x",
			},
		},
		system_prompt = function()
			local hub = require("mcphub").get_hub_instance()

			if hub == nil then
				-- if mcphub is not loaded, return nil
				-- this will use the default system prompt
				return nil
			end
			return hub:get_active_servers_prompt()
		end,
		-- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
		custom_tools = function()
			return {
				require("mcphub.extensions.avante").mcp_tool(),
			}
		end,
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"echasnovski/mini.pick", -- for file_selector provider mini.pick
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"ibhagwan/fzf-lua", -- for file_selector provider fzf
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-3-5-sonnet-20241022",
				temperature = 0,
				max_tokens = 4096,
			},
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()

				if hub == nil then
					-- if mcphub is not loaded, return nil
					-- this will use the default system prompt
					return nil
				end
				return hub:get_active_servers_prompt()
			end,
			-- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
			custom_tools = function()
				require("avante").setup({
					file_selector = {
						provider = "telescope", -- or "fzf", "mini.pick"
						-- provider = "fzf", -- or "telescope", "mini.pick"
						-- provider = "mini.pick", -- or "telescope", "fzf"
					},
					providers = { "ollama", "devstral", "openai", "anthropic" }, -- or 'copilot'
				})
				return {
					require("mcphub.extensions.avante").mcp_tool(),
				}
			end,
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante", "vimwiki" },
					latex = { enabled = false },
				},
				ft = { "markdown", "Avante" },
				init = function()
					vim.treesitter.language.register("markdown", "vimwiki")
				end,
			},
		},
		keys = function(_, keys)
			---@type avante.Config
			local opts = require("lazy.core.plugin").values(
				require("lazy.core.config").spec.plugins["avante.nvim"],
				"opts",
				false
			)

			local mappings = {
				{
					opts.mappings.ask,
					function()
						require("avante.api").ask()
					end,
					{ "n", "v" },
					desc = "avante: ask",
				},
				{
					opts.mappings.new_ask,
					function()
						require("avante.api").ask({ new_chat = true })
					end,
					{ "n", "v" },
					desc = "avante: create new ask",
				},
				{
					opts.mappings.edit,
					function()
						require("avante.api").edit()
					end,
					"v",
					desc = "avante: edit",
				},
				{
					opts.mappings.stop,
					function()
						require("avante.api").stop()
					end,
					"n",
					desc = "avante: stop",
				},
				{
					opts.mappings.refresh,
					function()
						require("avante.api").refresh()
					end,
					"n",
					desc = "avante: refresh",
				},
				{
					opts.mappings.focus,
					function()
						require("avante.api").focus()
					end,
					"n",
					desc = "avante: focus",
				},
				{
					opts.mappings.toggle.default,
					function()
						require("avante").toggle()
					end,
					"n",
					desc = "avante: toggle",
				},
				{
					opts.mappings.toggle.debug,
					function()
						require("avante").toggle.debug()
					end,
					"n",
					desc = "avante: toggle debug",
				},
				{
					opts.mappings.toggle.hint,
					function()
						require("avante").toggle.hint()
					end,
					"n",
					desc = "avante: toggle hint",
				},
				{
					opts.mappings.toggle.suggestion,
					function()
						require("avante").toggle.suggestion()
					end,
					"n",
					desc = "avante: toggle suggestion",
				},
				{
					opts.mappings.toggle.repomap,
					function()
						require("avante.repo_map").show()
					end,
					"n",
					desc = "avante: display repo map",
				},
				{
					opts.mappings.select_model,
					function()
						require("avante.api").select_model()
					end,
					"n",
					desc = "avante: select model",
				},
				{
					opts.mappings.select_history,
					function()
						require("avante.api").select_history()
					end,
					"n",
					desc = "avante: select history",
				},
				{
					opts.mappings.files.add_all_buffers,
					function()
						require("avante.api").add_buffer_files()
					end,
					"n",
					desc = "avante: add all open buffers",
				},
				-- Suggestion keymaps
				{
					opts.mappings.suggestion.accept,
					function()
						local _, _, sg = require("avante").get()
						sg:accept()
					end,
					"i",
					desc = "avante: accept suggestion",
				},
				-- Git conflict resolution keymaps
				{
					opts.mappings.diff.ours,
					function()
						require("avante.diff").choose("ours")
					end,
					{ "n", "v" },
					desc = "avante: choose our changes",
				},
				{
					opts.mappings.diff.both,
					function()
						require("avante.diff").choose("both")
					end,
					{ "n", "v" },
					desc = "avante: choose both changes",
				},
				{
					opts.mappings.diff.theirs,
					function()
						require("avante.diff").choose("theirs")
					end,
					{ "n", "v" },
					desc = "avante: choose their changes",
				},
				{
					opts.mappings.diff.all_theirs,
					function()
						require("avante.diff").choose("all_theirs")
					end,
					{ "n", "v" },
					desc = "avante: choose all their changes",
				},
				{
					opts.mappings.diff.cursor,
					function()
						require("avante.diff").choose("cursor")
					end,
					{ "n", "v" },
					desc = "avante: choose changes at cursor",
				},
				{
					opts.mappings.diff.next,
					function()
						require("avante.diff").find_next("ours")
					end,
					"n",
					desc = "avante: go to next conflict",
				},
				{
					opts.mappings.diff.prev,
					function()
						require("avante.diff").find_prev("ours")
					end,
					"n",
					desc = "avante: go to previous conflict",
				},
				{
					opts.mappings.suggestion.dismiss,
					function()
						local _, _, sg = require("avante").get()
						if sg:is_visible() then
							sg:dismiss()
						end
					end,
					"i",
					desc = "avante: dismiss suggestion",
				},
				{
					opts.mappings.suggestion.next,
					function()
						local _, _, sg = require("avante").get()
						sg:next()
					end,
					"i",
					desc = "avante: next suggestion",
				},
				{
					opts.mappings.suggestion.prev,
					function()
						local _, _, sg = require("avante").get()
						sg:prev()
					end,
					"i",
					desc = "avante: previous suggestion",
				},
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)

			return vim.list_extend(mappings, keys)
		end,
	},
}
