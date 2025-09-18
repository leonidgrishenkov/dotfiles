return {
    { "folke/tokyonight.nvim", enabled = false },
    {
        "catppuccin/nvim",
        opts = {
            flavour = "frappe", -- Can be one of: latte, frappe, macchiato, mocha
            transparent_background = true,
            float = {
                transparent = true,
                solid = false,
            },
            term_colors = false,
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            auto_integrations = true,
            integrations = {
                blink_cmp =true,
                native_lsp = {
                    enabled = true,
                    -- To see all available values: :h highlight-args
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "undercurl" },
                        hints = {},
                        warnings = { "undercurl" },
                        information = {},
                        ok = {},
                    },
                },
            },
        },
    },
}
