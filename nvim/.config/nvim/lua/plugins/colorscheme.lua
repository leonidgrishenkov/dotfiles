return {
    {
        -- Repo: https://github.com/catppuccin/nvim
        -- Docs: `:h catppuccin`
        "catppuccin/nvim",
        lazy = false, -- `false` means that we load this plugin during startup
        priority = 1000, -- make sure to load this before all the other start plugins
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "frappe", -- Can be one of: latte, frappe, macchiato, mocha
                transparent_background = true,
                term_colors = true,
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                styles = {
                    -- To see all available values: `:h highlight-args`
                    comments = {},
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                -- About integrations: https://github.com/catppuccin/nvim#integrations
                integrations = {
                    nvimtree = true,
                    cmp = true,
                    telescope = true,
                    treesitter = true,
                    telescope = true,
                    mason = true,
                    markdown = true,
                    indent_blankline = { enabled = true },
                    native_lsp = {
                        enabled = true,
                        underlines = {
                            errors = { "undercurl" },
                            hints = { "undercurl" },
                            warnings = { "undercurl" },
                            information = { "undercurl" },
                        },
                    },
                },
            })
            vim.cmd("colorscheme catppuccin")
        end,
    },
}
