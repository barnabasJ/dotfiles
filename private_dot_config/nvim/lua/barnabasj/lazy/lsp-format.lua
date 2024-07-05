return {
    "lukas-reineke/lsp-format.nvim",
    config = function()
        local prettier = {
            configPrecedence = "prefer-file",
            exclude = { "tsserver", "jsonls" },
        }

        require("lsp-format").setup {
            typescript = prettier,
            javascript = prettier,
            typescriptreact = prettier,
            javascriptreact = prettier,
            json = prettier,
            css = prettier,
            scss = prettier,
            html = prettier,
            yaml = {
                tabWidth = function()
                    return vim.opt.shiftwidth
                end,
                singleQuote = true,
                trailingComma = "all",
                configPrecedence = "prefer-file",
            },
            python = {
                lineLength = 120,
            },
            markdown = prettier,
            sh = {
                tabWidth = function()
                    return vim.opt.shiftwidth
                end,
            },
        }
    end
}
