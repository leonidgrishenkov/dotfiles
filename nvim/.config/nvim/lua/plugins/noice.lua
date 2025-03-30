---@diagnostic disable: missing-fields
return {
    {
        --[[
        This plugin replace standart UI for messages, cmdline and popupmenu.

        Repo: https://github.com/folke/noice.nvim
        Wiki: https://github.com/folke/noice.nvim/wiki
        Help: :h noice

        Commands:
        - `:checkhealth noice` - Check health
        - `:Noice` or `:Noice history` shows the message history
        - `:Noice last` shows the last message in a popup
        - `:Noice dismiss` dismiss all visible messages
        - `:Noice errors` shows the error messages in a split. Last errors on top
        - `:Noice disable` disables **Noice**
        - `:Noice enable` enables **Noice**
        - `:Noice stats` shows debugging stats
        - `:Noice telescope` opens message history in Telescope
        ]]
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim", -- Repo: https://github.com/MunifTanjim/nui.nvim
            "hrsh7th/nvim-cmp",
            "rcarriga/nvim-notify",
        },
        -- :h noice.nvim-noice-configuration
        opts = {
            cmdline = {
                ---@type table<string, CmdlineFormat>
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = { pattern = "^:", icon = "󱐋", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
                    lua = {
                        pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
                        icon = "",
                        lang = "lua",
                    },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                },
            },
            ---@type NoiceRouteConfig[]
            routes = {
                {
                    -- Show @recording messages as a notify message.
                    view = "notify",
                    filter = { event = "msg_showmode" },
                },
                {
                    -- Always route any messages with more than 20 lines to the split view
                    view = "split",
                    filter = { event = "msg_show", min_height = 20 },
                },
                {
                    -- Hide all messages about written files
                    filter = {
                        event = "msg_show",
                        kind = "",
                        find = "written",
                    },
                    opts = { skip = true },
                },
            },
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
                hover = {
                    silent = true, -- set to true to not show a message if hover is not available
                },
            },
            ---@type NoiceConfigViews
            views = {
                notify = {
                    -- When true, messages routing to the same notify
                    -- instance will replace existing messages instead of
                    -- pushing a new notification every time.
                    replace = true,
                },
                -- The following line are configure to display the Cmdline and Popupmenu together.
                cmdline_popup = {
                    position = {
                        row = 5,
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = "auto",
                    },
                    win_options = {
                        winhighlight = {
                            NormalFloat = "NormalFloat",
                            FloatBorder = "FloatBorder",
                        },
                    },
                },
                popupmenu = {
                    relative = "editor",
                    position = {
                        row = 8,
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = 10,
                    },
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                    -- nui options
                    win_options = {
                        winhighlight = {
                            -- UI text highlight group
                            Normal = "Normal",
                            -- UI menu border highlight group
                            FloatBorder = "FloatBorder",
                        },
                    },
                },
            },
            presets = {
                -- inc_rename = true, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
        },
        init = function()
            -- LSP hover doc scrolling
            -- Source: help
            vim.keymap.set({ "n", "i", "s" }, "<c-j>", function()
                if not require("noice.lsp").scroll(4) then
                    return "<c-j>"
                end
            end, { silent = true, expr = true })

            vim.keymap.set({ "n", "i", "s" }, "<c-k>", function()
                if not require("noice.lsp").scroll(-4) then
                    return "<c-k>"
                end
            end, { silent = true, expr = true })
        end,
    },
}
