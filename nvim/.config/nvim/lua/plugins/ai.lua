-- AI inline completions via minuet-ai.nvim + OpenRouter
-- https://github.com/milanglacier/minuet-ai.nvim
--
-- Uses virtual text (ghost text) frontend, not blink.cmp menu.
--
-- Virtual text keymaps (insert mode):
--   <A-A>     accept whole completion
--   <A-a>     accept one line
--   <A-z>     accept N lines (prompts for count, e.g. "A-z 3 CR")
--   <A-]>     next suggestion / manually invoke
--   <A-[>     prev suggestion / manually invoke
--   <A-e>     dismiss suggestion
return {
    {
        "milanglacier/minuet-ai.nvim",
        event = "InsertEnter",
        enabled = false,
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
                -- disable blink auto-complete (we use virtualtext instead)
                blink = {
                    enable_auto_complete = false,
                },
                virtualtext = {
                    -- auto-trigger in all filetypes; set e.g. { "lua", "python" }
                    -- to restrict, or use auto_trigger_ignore_ft to exclude
                    auto_trigger_ft = { "*" },
                    keymap = {
                        accept = "<A-A>",
                        accept_line = "<A-a>",
                        accept_n_lines = "<A-z>",
                        next = "<A-]>",
                        prev = "<A-[>",
                        dismiss = "<A-e>",
                    },
                },
            })
        end,
    },
}
