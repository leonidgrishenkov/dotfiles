return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        enabled = false,
        lazy = false,
        version = false, -- set this if you want to always pull the latest change
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        config = function()
            require("avante").setup({
                provider = "claude",
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-3-5-sonnet-20241022",
                    temperature = 0,
                    max_tokens = 4096,
                },
                hints = { enabled = false },
            })
        end,
    },
}
