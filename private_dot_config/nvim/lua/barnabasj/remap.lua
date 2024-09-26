local wk = require("which-key")
-- config
wk.add({
    {
        "<leader><leader>",
        function()
            vim.cmd("so")
        end,
        desc = "Reload config",
    },
})
-- netrw
wk.add({
    { "<leader>f",  group = "File" },
    { "<leader>fe", vim.cmd.Ex,    desc = "Open explorer" },
})

-- convenience
wk.add({
    { "<ESC>", "<cmd>nohlsearch<CR>", desc = "clear hl search" },
})
