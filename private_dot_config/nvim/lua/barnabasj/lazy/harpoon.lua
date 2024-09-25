return {

    {
        "theprimeagen/harpoon",

        config = function()
            require("harpoon").setup({})

            local wk = require("which-key")

            wk.add({
                { "<leader>h",  group = "Harpoon" },
                { "<leader>hm", require("harpoon.ui").toggle_quick_menu, desc = "Menu" },
                { "<leader>hn", require("harpoon.ui").nav_next,          desc = "next" },
                { "<leader>hp", require("harpoon.ui").nav_prev,          desc = "prev" },
                { "<leader>ha", require("harpoon.mark").add_file,        desc = "add file" },
                { "<leader>hr", require("harpoon.mark").rm_file,         desc = "remove file" },
            })
        end,
    },
}
