return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>tf",
			function()
				-- If autoformat is currently disabled for this buffer,
				-- then enable it, otherwise disable it
				if vim.b.disable_autoformat then
					vim.cmd("FormatEnable")
					vim.notify("Enabled autoformat for current buffer")
				else
					vim.cmd("FormatDisable!")
					vim.notify("Disabled autoformat for current buffer")
				end
			end,
			desc = "Toggle autoformat for current buffer",
		},
		{
			"<leader>tF",
			function()
				-- If autoformat is currently disabled globally,
				-- then enable it globally, otherwise disable it globally
				if vim.g.disable_autoformat then
					vim.cmd("FormatEnable")
					vim.notify("Enabled autoformat globally")
				else
					vim.cmd("FormatDisable")
					vim.notify("Disabled autoformat globally")
				end
			end,
			desc = "Toggle autoformat globally",
		},
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		formatters = {
			sql_formatter = {
				args = function()
					return { "-l", "postgresql" } -- Replace "postgresql" with your desired SQL dialect
				end,
			},
			-- Run the project's own `mix format` over stdin. Because it reads
			-- the project's .formatter.exs, this also runs the
			-- Phoenix.LiveView.HTMLFormatter plugin and — on LiveView
			-- 1.2.0-rc.0+ — its TagFormatter behaviour, which is what formats
			-- the JS/CSS inside colocated <script>/<style> tags (via prettier)
			-- in ~H sigils. `mix format` is a compile-time pass, so it formats
			-- that content regardless of the editor's treesitter/LSP setup.
			--
			-- `--stdin-filename` is required so mix picks the right formatter
			-- by extension (.heex -> heex plugin; without it stdin is assumed
			-- to be .exs). `require_cwd` keeps it from erroring on stray .ex
			-- files outside a mix project — conform then LSP-formats instead.
			--
			-- cwd is a function (not `require("conform.util").root_file(...)`)
			-- because the spec table is evaluated before conform.nvim loads, so
			-- requiring it here at module-load time fails.
			mix_format = {
				command = "mix",
				args = function(_, ctx)
					return { "format", "--stdin-filename", ctx.filename, "-" }
				end,
				stdin = true,
				cwd = function(_, ctx)
					return vim.fs.root(ctx.dirname, { "mix.exs", ".formatter.exs" })
				end,
				require_cwd = true,
			},
		},
		notify_on_error = false,
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			local ft = vim.bo[bufnr].filetype
			local lsp_format_opt
			if disable_filetypes[ft] then
				lsp_format_opt = "never"
			else
				lsp_format_opt = "fallback"
			end
			-- `mix format` cold-starts the BEAM (~1-2s), so the default 500ms
			-- would time out and silently skip on save. Give Elixir/HEEx room.
			local timeout = (ft == "elixir" or ft == "heex") and 3000 or 500
			return {
				timeout_ms = timeout,
				lsp_format = lsp_format_opt,
			}
		end,
		formatters_by_ft = {
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- Elixir/HEEx go through `mix format` so colocated <script>/<style>
			-- contents get formatted by the LiveView HTMLFormatter TagFormatter.
			elixir = { "mix_format" },
			heex = { "mix_format" },
			html = { "prettier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			graphql = { "prettier" },
			json = { "prettier" },
			lua = { "stylua" },
			markdown = { "prettier" },
			sql = { "sql_formatter" },
			yaml = { "prettier" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				-- :FormatDisable! disables autoformat for this buffer only
				vim.b.disable_autoformat = true
			else
				-- :FormatDisable disables autoformat globally
				vim.g.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true, -- allows the ! variant
		})

		vim.api.nvim_create_user_command("FormatEnable", function()
			vim.b.disable_autoformat = false
			vim.g.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
}
