return {
    {
        "folke/which-key.nvim",
        opts = {
            ---@type false | "classic" | "modern" | "helix"
            preset = "modern",
            icons = {
                rules = false, -- don't show icons in UI
                mappings = false,
                breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                separator = "➜", -- symbol used between a key and it's label
                group = "", -- symbol prepended to a group
                ellipsis = "..",
            },
            win = {
                no_overlap = false,
                border = "rounded",
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        opts = function(_, opts)
            -- Disable all items in signcolumn
            opts.signs = false
        end,
    },
    {
        "nvim-mini/mini.move",
        event = "VeryLazy",
        opts = {
            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
                left = "<C-h>",
                right = "<C-l>",
                down = "<C-j>",
                up = "<C-k>",

                -- Move current line in Normal mode
                line_left = "",
                line_right = "",
                line_down = "",
                line_up = "",
            },
        },
    },
}
