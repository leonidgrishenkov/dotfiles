return {
    {
        -- AI inline completions via minuet-ai.nvim + OpenRouter
        -- https://github.com/milanglacier/minuet-ai.nvim
        --
        -- Runtime commands:
        --   :Minuet blink toggle     -- enable/disable autocomplete in blink.cmp
        --   :Minuet blink enable     -- force enable
        --   :Minuet blink disable    -- force disable
        --   :Minuet change_provider  -- switch LLM provider (claude, gemini, openai, etc.)
        --   :Minuet change_model     -- switch model interactively
        --
        -- lazy.nvim plugin management:
        --   :Lazy disable minuet-ai.nvim  -- prevent from loading at startup
        --   :Lazy enable minuet-ai.nvim   -- re-enable loading
        --   :Lazy clear minuet-ai.nvim    -- uninstall plugin
        "milanglacier/minuet-ai.nvim",
        event = "InsertEnter",
        config = function()
            require("minuet").setup({
                provider = "openai_compatible",
                provider_options = {
                    openai_compatible = {
                        api_key = "OPENROUTER_API_KEY",
                        end_point = "https://openrouter.ai/api/v1/chat/completions",
                        model = "google/gemini-2.5-flash",
                        name = "Openrouter",
                        optional = {
                            max_tokens = 128,
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
    {
        "saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                default = { "lsp", "buffer", "path", "minuet" },
                providers = {
                    minuet = {
                        name = "minuet",
                        module = "minuet.blink",
                        async = true,
                        timeout_ms = 3000,
                        score_offset = 100,
                    },
                },
            },
            completion = {
                trigger = { prefetch_on_insert = false },
            },
        },
    },
}
