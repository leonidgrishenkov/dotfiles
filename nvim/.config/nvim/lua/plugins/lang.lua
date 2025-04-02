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
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.diagnostics = vim.tbl_extend("force", opts.diagnostics, {
                float = {
                    -- Always show diagnostic source (LSP server or linter)
                    source = true,
                    -- Enable border for floating window
                    border = "rounded",
                },
            })
        end,
    },
}
