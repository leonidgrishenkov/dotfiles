return {
    {
        "folke/noice.nvim",
        opts = {
            presets = {
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true,
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            sections = {
                lualine_b = { { "branch", icon = " " } },
                lualine_z = {
                    {
                        "filetype",
                        colored = false, -- Displays filetype icon in color if set to true
                        icon_only = false, -- Display only an icon for filetype
                    },
                },
            },
        },
    },
    {
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            ---@class snacks.explorer.Config
            explorer = {
                trash = true, -- Use the system trash when deleting files
            },
            picker = {
                sources = {
                    explorer = {
                        hidden = true, -- show dotfiles in explorer
                        ignored = true, -- show gitignore files in explorer
                    },
                    files = {
                        hidden = true, -- show dotfiles in finder
                        ignored = true, -- show gitignored files in finder
                    },
                },
            },
        },
    },
}
