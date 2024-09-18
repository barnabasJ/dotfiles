return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		local eslint = require("efmls-configs.linters.eslint")
		local prettier = require("efmls-configs.formatters.prettier")

		local sqlfluff = require("efmls-configs.linters.sqlfluff")

		local languages = require("efmls-configs.defaults").languages()

		-- TODO: make this more dynamic
		-- https://github.com/creativenull/efmls-configs-nvim/blob/a61c52d325835e24dc14ffb7748a32b8f087ae32/lua/efmls-configs/fs.lua#L8
		-- same logic with parent dir traversal would be nice for config files
		local fs = require("efmls-configs.fs")
		local command = string.format("%s fix -q --disable-progress-bar -", fs.executable("sqlfluff"))

		local sqlfluff_format = {
			formatCommand = command,
			formatStdin = true,
		}

		languages = vim.tbl_extend("force", languages, {
			typescript = { prettier, eslint },
			typescriptreact = { prettier, eslint },
			markdown = { prettier },
			graphql = { prettier },
			yaml = { prettier },
			sql = { sqlfluff },
			dbt = { sqlfluff, sqlfluff_format },
		})

		require("fidget").setup({})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"sqlls",
				"bashls",
				"yamlls",
				"lua_ls",
				"rust_analyzer",
				"elixirls",
				"efm",
				"zls",
			},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						on_attach = require("lsp-format").on_attach,
						capabilities = capabilities,
					})
				end,

				["efm"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.efm.setup({
						on_attach = require("lsp-format").on_attach,
						capabilities = capabilities,
						init_options = { documentFormatting = true },
						root_dir = vim.loop.cwd,
						filetypes = vim.tbl_keys(languages),
						settings = {
							rootMarkers = { ".git/" },
							lintDebounce = "500ms",
							languages = languages,
						},
					})
				end,

				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						on_attach = require("lsp-format").on_attach,
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
				["yamlls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.yamlls.setup({
						on_attach = require("lsp-format").on_attach,
						capabilities = capabilities,
						settings = {
							yaml = {
								format = {
									enable = false,
								},
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})

		vim.diagnostic.config({
			-- update_in_insert = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				header = "",
				prefix = "",
			},
		})
	end,
}
