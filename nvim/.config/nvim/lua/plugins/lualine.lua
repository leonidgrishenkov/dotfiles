return {
    {
        -- Repo: https://github.com/nvim-lualine/lualine.nvim
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function(_, opts)
            local icons = require("utils.icons")

            return {
                options = {
                    icons_enabled = true,
                    globalstatus = true,
                    theme = "catppuccin",
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                },
                sections = {
                    --[[
                    `lualine` sestions:
                    +-------------------------------------------------+
                    | A | B | C                             X | Y | Z |
                    +-------------------------------------------------+

                    Available components: https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#changing-components-in-lualine-sections
                    --]]
                    lualine_a = { { "mode", icons_enabled = true } },
                    lualine_b = {
                        { "branch", icon = icons.git.Branch },
                        {
                            "progress",
                        },
                        {
                            "diff",
                            symbols = { added = icons.git.Add, modified = icons.git.Mod, removed = icons.git.Remove },
                        },
                        {
                            "diagnostics",
                            symbols = {
                                error = icons.diagnostics.Error,
                                warn = icons.diagnostics.Warn,
                                hint = icons.diagnostics.Hint,
                                info = icons.diagnostics.Info,
                            },
                            update_in_insert = true,
                        },
                    },
                    lualine_c = {
                        {
                            "buffers",
                            show_filename_only = true, -- Shows shortened relative path when set to false.
                            hide_filename_extension = false, -- Hide filename extension when set to true.
                            show_modified_status = true, -- Shows indicator when the buffer is modified.
                            mode = 0, -- 0: Shows buffer name
                            -- 1: Shows buffer index
                            -- 2: Shows buffer name + buffer index
                            -- 3: Shows buffer number
                            -- 4: Shows buffer name + buffer number

                            max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
                            -- it can also be a function that returns
                            -- the value of `max_length` dynamically.
                            filetype_names = {
                                TelescopePrompt = "Telescope",
                                dashboard = "Dashboard",
                                fzf = "FZF",
                                NvimTree = "NvimTree",
                            },
                            symbols = {
                                modified = " ●",
                                alternate_file = "", -- Text to show to identify the alternate file
                                directory = "", -- Text to show when the buffer is a directory
                            },
                        },
                    },
                    lualine_x = {},
                    lualine_y = {
                        {
                            "filename",
                            file_status = false, -- Displays file status (readonly status, modified status)
                            newfile_status = false, -- Display new file status (new file means no write after created)
                            --[[
                            Available options:
                                0: Just the filename
                                1: Relative path
                                2: Absolute path
                                3: Absolute path, with tilde as the home directory
                                4: Filename and parent dir, with tilde as the home directory
                            --]]
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = "", -- Text to show when the file is non-modifiable or readonly.
                                unnamed = "", -- Text to show for unnamed buffers.
                                newfile = "󰎔", -- Text to show for newly created file before first write
                            },
                        },
                    },
                    lualine_z = {
                        {
                            "filetype",
                            colored = false, -- Displays filetype icon in color if set to true
                            icon_only = false, -- Display only an icon for filetype
                        },
                    },
                },
            }
        end,
    },
}
