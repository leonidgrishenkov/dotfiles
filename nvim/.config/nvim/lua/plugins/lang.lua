return {
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
                -- Add border for Mason window
                border = "rounded",
            },
            ensure_installed = {
                "stylua",
                "prettierd",
                "sqlfluff",
                "yamllint",
                "shfmt",
            },
        },
    },
}
