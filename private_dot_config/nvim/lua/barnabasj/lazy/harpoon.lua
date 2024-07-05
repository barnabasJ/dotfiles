return {

    {
        "theprimeagen/harpoon",

        config = function()
            require('harpoon').setup({})

            local wk = require("which-key")

            wk.register({
                h = {
                    name = "Harpoon",
                    m = { require("harpoon.ui").toggle_quick_menu, "Menu" },
                    n = { require("harpoon.ui").nav_next, "next" },
                    p = { require("harpoon.ui").nav_prev, "prev" },
                    a = { require("harpoon.mark").add_file, "add file" },
                    r = { require("harpoon.mark").rm_file, "remove file" }
                },
            }, { prefix = "<leader>" })
        end
    }
}
