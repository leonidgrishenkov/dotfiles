return {
    { "folke/tokyonight.nvim", enabled = false },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            -- flavor can be one of: latte, frappe, macchiato, mocha
            flavour = "auto",
            background = {
                light = "latte",
                dark = "macchiato",
            },
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
            styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = {},
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
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                    ok = { "italic" },
                },
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = {},
                    information = {},
                    ok = {},
                },
                inlay_hints = {
                    background = true,
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
                    BlinkCmpMenuSelection = { bg = colors.grey, fg = colors.text },
                    BlinkCmpLabel = { bg = colors.none },
                }
            end,
        },
        specs = {
            {
                "akinsho/bufferline.nvim",
                optional = true,
                opts = function(_, opts)
                    if (vim.g.colors_name or ""):find("catppuccin") then
                        opts.highlights = require("catppuccin.special.bufferline").get_theme()
                    end
                end,
            },
        },
    },
}
