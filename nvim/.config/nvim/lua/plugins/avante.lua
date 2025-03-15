return {
    {
        -- https://github.com/yetone/avante.nvim
        "yetone/avante.nvim",
        event = "VeryLazy",
        enabled = true,
        lazy = false,
        version = false, -- set this if you want to always pull the latest change
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        config = function()
            require("avante").setup({
                provider = "claude",
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-3-7-sonnet-20250219",
                    temperature = 0,
                    max_tokens = 10000,
                },
                hints = { enabled = false },
            })
        end,
    },
}
