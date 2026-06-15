return {
    {
        "saghen/blink.cmp",
        opts = {
            appearance = {
                -- sets the fallback highlight groups to nvim-cmp's highlight groups
                -- useful for when your theme doesn't support blink.cmp
                -- will be removed in a future release, assuming themes add support
                use_nvim_cmp_as_default = true,
            },
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
            -- recommended: avoid unnecessary LLM requests on insert
            completion = {
                trigger = { prefetch_on_insert = false },
                list = { selection = { preselect = false, auto_insert = false } },
                menu = {
                    border = "rounded",
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                documentation = { window = { border = "rounded" } },
            },
            -- manual invoke minuet with Alt+y
            keymap = {
                ["<A-y>"] = {
                    function(cmp)
                        cmp.show({ providers = { "minuet" } })
                    end,
                },
            },
            signature = { window = { border = "rounded" } },
        },
    },
}
