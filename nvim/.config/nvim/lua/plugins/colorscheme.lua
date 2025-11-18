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
                blink_cmp = true,
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
            custom_highlights = function(colors)
                return {
                    -- Standard Neovim completion menu groups
                    Pmenu = { bg = colors.none },
                    PmenuSel = { bg = colors.surface0, fg = colors.text },
                    PmenuBorder = { bg = colors.none },
                    PmenuSbar = { bg = colors.none },
                    PmenuThumb = { bg = colors.overlay0 },
                    NormalFloat = { bg = colors.none },
                    TabLineSel = { bg = colors.pink },
                    CmpBorder = { fg = colors.surface2 },
                    -- Blink.cmp specific groups
                    BlinkCmpMenu = { bg = colors.none },
                    BlinkCmpMenuBorder = { bg = colors.none },
                    BlinkCmpDoc = { bg = colors.none },
                    BlinkCmpDocBorder = { bg = colors.none },
                    BlinkCmpMenuSelection = { bg = colors.none },
                    BlinkCmpLabel = { bg = colors.none },
                }
            end,
        },
    },
}
