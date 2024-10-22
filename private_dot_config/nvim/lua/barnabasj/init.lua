require("barnabasj.globals")
require("barnabasj.options")
require("barnabasj.lazy_init")
require("barnabasj.autocomands")
require("barnabasj.remap")

-- Thanks Claude for these two functions
-- Function to check if any LSP client can format
local function has_formatter()
	for _, client in pairs(vim.lsp.get_active_clients()) do
		if client.server_capabilities.documentFormattingProvider then
			return true
		end
	end
	return false
end

-- Smart format function that tries LSP first, then conform
local function smart_format()
	if has_formatter() then
		vim.lsp.buf.format()
	else
		-- Make sure conform is available
		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format()
		else
			vim.notify("No formatter available (neither LSP nor conform.nvim)", vim.log.levels.WARN)
		end
	end
end

-- TODO: check if this is still needed
-- I think this is still configured in the lsp file
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("Barnabasj", { clear = true }),
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
		require("which-key").add({
			buffer = e.buf,
			{ "<leader>l", group = "LSP" },
			{
				"<leader>lf",
				smart_format,
				desc = "Format the current buffer",
			},
			{ "<leader>lg", group = "Goto" },
			{ "<leader>lgd", vim.lsp.buf.definition, desc = "Go to definition" },
			{
				"<leader>lgr",
				require("telescope.builtin").lsp_references,
				desc = "Open a telescope window with references",
			},
		})
	end,
})
