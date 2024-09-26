require("barnabasj.globals")
require("barnabasj.options")
require("barnabasj.lazy_init")
require("barnabasj.autocomands")
require("barnabasj.remap")

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
            { "<leader>l",   group = "LSP" },
            {
                "<leader>lf",
                function()
                    vim.lsp.buf.format({
                        filter = function(client)
                            return client.name ~= "tsserver"
                        end,
                    })
                end,
                desc = "Format the current buffer",
            },
            { "<leader>lg",  group = "Goto" },
            { "<leader>lgd", vim.lsp.buf.definition, desc = "Go to definition" },
            {
                "<leader>lgr",
                require("telescope.builtin").lsp_references,
                desc = "Open a telescope window with references",
            },
        })
    end,
})
