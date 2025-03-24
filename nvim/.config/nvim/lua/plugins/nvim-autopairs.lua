return {
    {
        --[[
        Creates autopairs for sertan sybols: `{`, `[` etc.

        Repo: https://github.com/windwp/nvim-autopairs
        Wiki: https://github.com/windwp/nvim-autopairs/wiki
        Dos: :h nvim-autopairs
        --]]
        "windwp/nvim-autopairs",
        event = {
            "InsertEnter",
        },
        -- Example: https://github.com/josean-dev/dev-environment-files/blob/main/.config/nvim/lua/josean/plugins/nvim-autopairs.lua
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        config = function()
            -- Import plugin
            local autopairs = require("nvim-autopairs")
            -- Configure plugin
            autopairs.setup({
                check_ts = true, -- enable treesitter
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                ts_config = {
                    lua = { "string" }, -- don't add pairs in lua string treesitter nodes
                },
            })

            -- import nvim-autopairs completion functionality
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")

            -- import nvim-cmp plugin (completions plugin)
            local cmp = require("cmp")

            -- make autopairs and completion work together
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
}
