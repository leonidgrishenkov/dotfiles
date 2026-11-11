local icons = require("utils.icons")

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
                lualine_b = { { "branch", icon = "󰊢 " } },
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
                -- exclude = { "**/node_modules/**" }, -- ignore node_modules completely
            },
            picker = {
                icons = {
                    diagnostics = icons.diagnostics,
                    git = {
                        ignored = icons.git.ignored,
                        modified = icons.git.modified,
                    },
                },
                sources = {
                    explorer = {
                        hidden = true, -- show dotfiles in explorer
                        ignored = true, -- show gitignore files in explorer
                        actions = {
                            -- Same as the built-in `explorer_yank` (`y`), but yanks `~/…` instead of `/Users/<me>/…`
                            explorer_yank = function(picker)
                                local files = {} ---@type string[]
                                if vim.fn.mode():find("^[vV]") then
                                    picker.list:select()
                                end
                                for _, item in ipairs(picker:selected({ fallback = true })) do
                                    table.insert(files, vim.fn.fnamemodify(Snacks.picker.util.path(item), ":~"))
                                end
                                picker.list:set_selected() -- clear selection
                                vim.fn.setreg(vim.v.register or "+", table.concat(files, "\n"), "l")
                                Snacks.notify.info("Yanked " .. #files .. " files")
                            end,
                        },
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
