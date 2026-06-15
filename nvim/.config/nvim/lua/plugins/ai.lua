return {
    {
        "milanglacier/minuet-ai.nvim",
        config = function()
            require("minuet").setup({
                provider = "openai_compatible",
                provider_options = {
                    openai_compatible = {
                        api_key = "OPENROUTER_API_KEY",
                        end_point = "https://openrouter.ai/api/v1/chat/completions",
                        model = "deepseek/deepseek-v4-flash",
                        name = "Openrouter",
                        optional = {
                            max_tokens = 56,
                            top_p = 0.9,
                            provider = {
                                sort = "throughput",
                            },
                            reasoning_effort = "none",
                        },
                    },
                },
                throttle = 1500,
                debounce = 600,
                request_timeout = 2.5,
                blink = {
                    enable_auto_complete = true,
                },
            })
        end,
    },
}
