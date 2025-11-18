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
            completion = {
                menu = {
                    border = "rounded",
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                documentation = { window = { border = "rounded" } },
            },
            signature = { window = { border = "rounded" } },
        },
    },
}
