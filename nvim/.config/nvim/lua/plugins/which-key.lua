return {
    {
        --[[
        Repo: https://github.com/folke/which-key.nvim

        Commands:
            - Check health: `checkhealth which-key`
        ]]
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300

            local wk = require("which-key")
            wk.setup({
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "➜", -- symbol used between a key and it's label
                    group = "", -- symbol prepended to a group
                },
                window = {
                    border = "single", -- none, single, double, shadow
                    position = "bottom", -- bottom, top
                    margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
                    padding = { 1, 0, 1, 0 }, -- extra window padding [top, right, bottom, left]
                },
                ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
            })
            -- NOTE: Here I defined only group names. For each keymap which-key automatically
            -- gets its description from keymap definition. Therefore we don't need
            -- to obviously specify any of them except keymaps without description.
            wk.register({
                -- Group for different Telescope search
                f = {
                    name = "Find",
                },
                -- Group for Git actions
                g = {
                    name = "Git",
                },
                -- Group for Comment actions
                c = {
                    name = "Comment",
                    l = "Comment/uncomment line/lines",
                    b = "Comment/uncomment block",
                },
                -- Group for LSP actions
                l = {
                    name = "LSP",
                },
                x = {
                    name = "Diagnostics",
                },
                s = {
                    name = "Search & Replace",
                },
                p = {
                    name = "Panes",
                },
            }, { prefix = "<leader>" })
        end,
    },
}
