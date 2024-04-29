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
                    treesitter = true,
                    ufo = true,
                    treesitter_context = true,
                    telescope = {
                        enabled = true,
                        style = "nvchad",
                    },
                    notify = true,
                    lsp_trouble = true,
                    gitsigns = true,
                    which_key = true,
                    mason = true,
                    markdown = true,
                    noice = true,
                    mini = true,
                    headlines = true,
                    fidget = true,
                    native_lsp = {
                        enabled = true,
                        virtual_text = {
                            errors = { "italic" },
                            hints = { "italic" },
                            warnings = { "italic" },
                            information = { "italic" },
                        },
                        underlines = {
                            errors = { "undercurl" },
                            hints = { "undercurl" },
                            warnings = { "undercurl" },
                            information = { "undercurl" },
                        },
                        inlay_hints = {
                            background = true,
                        },
                    },
                    --- @diagnostic disable: assign-type-mismatch
                    indent_blankline = {
                        enabled = true,
                        scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
                        colored_indent_levels = false,
                    },
                },
            })
            vim.cmd("colorscheme catppuccin")
        end,
    },
}
