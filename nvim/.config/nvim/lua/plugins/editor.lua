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
        opts = function (_, opts)
            -- Disable all items in signcolumn
            opts.signs = false
        end
    }
}

