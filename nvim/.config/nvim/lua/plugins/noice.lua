return {
    {
        --[[
        This plugin replace standart UI for messages, cmdline and popupmenu.

        Repo: https://github.com/folke/noice.nvim
        Wiki: https://github.com/folke/noice.nvim/wiki

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
        config = function()
            -- `:h noice.nvim-noice-configuration`
            require("noice").setup({
                cmdline = {
                    format = {
                        -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                        -- view: (default is cmdline view)
                        -- opts: any options passed to the view
                        -- icon_hl_group: optional hl_group for the icon
                        -- title: set to anything or empty string to hide
                        cmdline = { pattern = "^:", icon = "󱐋", lang = "vim" }, -- 󱐋 󰘳
                        search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" }, -- 󰆌 󰆋   
                        search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
                        filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
                        lua = {
                            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
                            icon = "",
                            lang = "lua",
                        },
                        help = { pattern = "^:%s*he?l?p?%s+", icon = "" }, -- 󰋖 󰞋 󰮥 󰘥 󰌵    󰋗 󰆋
                        -- input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
                    },
                },
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
                },
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    -- took from plugin repo
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                    },
                    hover = {
                        silent = true, -- set to true to not show a message if hover is not available
                    },
                },
                views = {
                    notify = {
                        -- When true, messages routing to the same notify
                        -- instance will replace existing messages instead of
                        -- pushing a new notification every time.
                        replace = true,
                    },
                },
                presets = {
                    bottom_search = false, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = true, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = true, -- add a border to hover docs and signature help
                },
            })
        end,
    },
}
