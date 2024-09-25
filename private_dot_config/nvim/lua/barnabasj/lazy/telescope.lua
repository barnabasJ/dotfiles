-- requires ripgrep and fzf to be installed
return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.5",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    config = function()
        require("telescope").setup({})

        local builtin = require("telescope.builtin")

        local wk = require("which-key")

        wk.add({
            { "<C-p>",      builtin.git_files },
            { "<leader>t",  group = "Telescope" },
            { "<leader>tf", builtin.find_files, desc = "file" },
            { "<leader>tg", builtin.git_files,  desc = "git file" },
            { "<leader>tl", builtin.live_grep,  desc = "word live" },
            { "<leader>to", builtin.oldfiles,   desc = "opened files" },
            { "<leader>tr", builtin.resume,     desc = "resume" },
            {
                "<leader>ts",
                function()
                    builtin.grep_string({ search = vim.fn.input("Grep for > ") })
                end,
                desc = "search",
            },
            { "<leader>tth", builtin.help_tags,   desc = "help" },
            { "<leader>tw",  builtin.grep_string, desc = "word" },
        })
    end,
}
