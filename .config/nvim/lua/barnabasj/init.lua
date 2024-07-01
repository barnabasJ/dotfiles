require("barnabasj.set")
require("barnabasj.remap")
require("barnabasj.lazy_init")

-- DO.not
-- DO NOT INCLUDE THIS

-- If i want to keep doing lsp debugging
-- function restart_htmx_lsp()
--     require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "DEBUG" }, root_dir = vim.loop.cwd(), });
-- end

-- DO NOT INCLUDE THIS
-- DO.not

local augroup = vim.api.nvim_create_augroup
local BarnabasJGroup = augroup("barnabasj", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})
local wk = require("which-key")

function R(name)
	require("plenary.reload").reload_module(name)
end

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

-- leader keys
wk.register({
	f = {
		name = "File",
		e = { vim.cmd.Ex, "Open explorer" },
	},
	c = {
		name = "Config",
		r = { "<cmd>source $MYVIMRC<CR>", "Reload config" },
	},
}, { prefix = "<leader>" })

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

autocmd("LspAttach", {
	group = BarnabasJGroup,
	callback = function(e)
		local opts = { buffer = e.buf }
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, opts)
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, opts)
		vim.keymap.set("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, opts)
		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, opts)
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, opts)
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, opts)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_next()
		end, opts)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_prev()
		end, opts)
		wk.register({
			l = {
				name = "LSP",
				g = {
					name = "Goto",
					d = { vim.lsp.buf.definition, "Go to definition" },
					r = {
						require("telescope.builtin").lsp_references,
						"Open a telescope window with references",
					},
				},
				f = {
					function()
						vim.lsp.buf.format({
							filter = function(client)
								return client.name ~= "tsserver"
							end,
						})
					end,
					"Format the current buffer",
				},
			},
		}, vim.tbl_extend("error", opts, { prefix = "<leader>" }))
	end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
