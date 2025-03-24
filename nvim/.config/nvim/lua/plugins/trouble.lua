return {
    {
        -- https://github.com/folke/trouble.nvim
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
        opts = {
            -- NOTE: Sings defined in lsp config
            use_diagnostic_signs = true,
            defaults = {
                focus = false, -- Focus the window when opened
            },
            modes = {
                lsp_references = {
                    -- some modes are configurable, see the source code for more details
                    params = {
                        include_declaration = false,
                    },
                },
            },
        },
        keys = {
            {
                "<leader>xw",
                ":Trouble diagnostics toggle<cr>",
                desc = "Toggle workspace diagnostics",
            },
            {
                "<leader>xb",
                ":Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Toggle buffer diagnostics",
            },
            {
                "<leader>xs",
                ":Trouble symbols toggle win.position=bottom<cr>",
                desc = "Toggle Symbols",
            },
            {
                "<leader>xS",
                ":Trouble lsp toggle win.position=bottom<cr>",
                desc = "Toggle LSP References",
            },
            {
                "<leader>xL",
                ":Trouble loclist toggle<cr>",
                desc = "Toggle location List",
            },
            {
                "<leader>xQ",
                ":Trouble qflist toggle<cr>",
                desc = "Toggle quickfix",
            },
            {
                "<leader>xt",
                ":TodoTrouble toggle<cr>",
                desc = "Toggle TODO",
            },
            {
                "<leader>xT",
                ":TodoTelescope<cr>",
                desc = "Toggle TODO in Telescope",
            },
        },
    },
}
