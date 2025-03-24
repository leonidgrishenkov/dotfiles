return {
    {
        -- Repo: https://github.com/catppuccin/nvim
        -- Docs: `:h catppuccin`
        "catppuccin/nvim",
        lazy = false, -- `false` means that we load this plugin during startup
        priority = 1000, -- make sure to load this before all the other start plugins
        name = "catppuccin",
        opts = {
            flavour = "frappe", -- Can be one of: latte, frappe, macchiato, mocha
            transparent_background = true, -- disables setting the background color.
            term_colors = false,
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
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
                barbecue = {
                    dim_dirname = true, -- directory name is dimmed by default
                    bold_basename = true,
                    dim_context = false,
                    alt_background = false,
                },
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
                semantic_tokens = true,
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
                        errors = {},
                        hints = {},
                        warnings = {},
                        information = {},
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
        },
        init = function()
            vim.cmd("colorscheme catppuccin")
        end,
    },
}
