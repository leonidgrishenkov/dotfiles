return {
    { "folke/tokyonight.nvim", enabled = false },
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        opts = {
            flavour = "frappe", -- Can be one of: latte, frappe, macchiato, mocha
            transparent_background = true, -- disables setting the background color.
            term_colors = false,
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            integrations = {
                rainbow_delimiters = true,
                blink_cmp = true,
            },
        },
    },
}
