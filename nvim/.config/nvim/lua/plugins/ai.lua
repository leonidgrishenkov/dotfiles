return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            -- NOTE: The log_level is in `opts.opts`
            opts = {
                log_level = "WARN", -- or "TRACE"
            },
            adapters = {
                http = {
                    openrouter = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url = "https://openrouter.ai/api",
                                api_key = "OPENROUTER_API_KEY",
                                chat_url = "/v1/chat/completions",
                            },
                            schema = {
                                model = {
                                    default = "anthropic/claude-sonnet-4-5",
                                },
                            },
                        })
                    end,
                },
            },
            strategies = {
                chat = { adapter = "openrouter" },
                inline = { adapter = "openrouter" },
            },
        },
    },
}
