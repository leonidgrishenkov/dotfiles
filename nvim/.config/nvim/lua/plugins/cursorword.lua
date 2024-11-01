return {
    {
        --[[
        https://github.com/xiyaowong/nvim-cursorword

        Commands:
            :CursorWordDisable
            :CursorWordToggle
            :CursorWordEnable
        --]]
        "xiyaowong/nvim-cursorword",
        event = "VeryLazy",
        config = function()
            -- Enable plugin only by manual trigger.
            vim.api.nvim_create_user_command("EnableCursorWord", function()
                vim.g.cursorword_highlight = true

                vim.g.cursorword_min_width = 2
                vim.g.cursorword_max_width = 30
                vim.g.cursorword_disable_filetypes = { "TelescopePrompt" }

                -- Configure UI higglight.
                vim.cmd("highlight CursorWord guibg=#909677 guifg=#f28fad")
                -- vim.cmd("hi! default link CursorWord CursorLine")
                -- vim.cmd("hi default CursorWord cterm=underline gui=underline")
                -- vim.cmd("highlight CursorWord guibg=#45475a guifg=#f28fad")
                -- vim.cmd("highlight CursorWord guifg=#e2f0b1") -- #f28fad
            end, {})

            -- Disable plugin by manual trigger.
            vim.api.nvim_create_user_command("DisableCursorWord", function()
                vim.g.cursorword_highlight = false
                vim.cmd("highlight! clear CursorWord")
            end, {})
        end,
    },
}
