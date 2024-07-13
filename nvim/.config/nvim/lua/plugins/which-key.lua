return {
    {
        --[[
        Repo: https://github.com/folke/which-key.nvim

        Commands:
            - Check health: `:checkhealth which-key`
        ]]
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300

            local wk = require("which-key")
            wk.setup({
                icons = {
                    rules = false, -- don't show icons in UI
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "➜", -- symbol used between a key and it's label
                    group = "", -- symbol prepended to a group
                    ellipsis = "…",
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
            wk.add({
                { "<leader>c", group = "Comment" },
                { "<leader>cb", desc = "Comment/uncomment block" },
                { "<leader>cl", desc = "Comment/uncomment line/lines" },
                { "<leader>f", group = "Find" },
                { "<leader>g", group = "Git" },
                { "<leader>l", group = "LSP" },
                { "<leader>p", group = "Panes" },
                { "<leader>s", group = "Search & Replace" },
                { "<leader>x", group = "Diagnostics" },
            })
        end,
    },
}
