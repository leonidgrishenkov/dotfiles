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
                menu = { border = "rounded" },
                documentation = { window = { border = "rounded" } },
            },
            signature = { window = { border = "rounded" } },
        },
        init = function()
            -- Change blink menu hl groups to regular ones to match base theme colors.
            -- https://cmp.saghen.dev/configuration/appearance.html#highlight-groups
            vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "NormalFloat" })
            vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "NormalFloat" })
        end,
    },
}
