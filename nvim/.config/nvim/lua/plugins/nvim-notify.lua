return {
    {
        --[[
        Better notifications in UI.
        https://github.com/rcarriga/nvim-notify

        Commands:
              :Telescope notify - Search history with Telescope.
        --]]
        "rcarriga/nvim-notify",
        config = function()
            --- @diagnostic disable: missing-fields
            -- :h notify.setup()
            require("notify").setup({
                background_colour = "#000000",
                timeout = 5000,
                -- Max width of message UI.
                max_width = 80,
                -- Appearence of the message.
                -- https://github.com/rcarriga/nvim-notify?tab=readme-ov-file#render-style
                render = "compact",
                -- Animation of them message.
                -- https://github.com/rcarriga/nvim-notify?tab=readme-ov-file#animation-style
                stages = "static",
            })

            -- Setup colors for UI
            -- vim.cmd([[
            --     highlight NotifyERRORBorder guifg=#ed8796
            --     highlight NotifyERRORIcon guifg=#ed8796
            --     highlight NotifyERRORTitle  guifg=#ed8796
            --     highlight NotifyINFOBorder guifg=#8aadf4
            --     highlight NotifyINFOIcon guifg=#8aadf4
            --     highlight NotifyINFOTitle guifg=#8aadf4
            --     highlight NotifyWARNBorder guifg=#f5a97f
            --     highlight NotifyWARNIcon guifg=#f5a97f
            --     highlight NotifyWARNTitle guifg=#f5a97f
            -- ]])
        end,
    },
}
