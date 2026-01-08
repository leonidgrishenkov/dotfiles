return {
    {
        "mason-org/mason.nvim",
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
            return opts
        end,
    },
    {
        "mfussenegger/nvim-lint",
        opts = function(_, opts)
            -- Remove SQL linters
            opts.linters_by_ft = opts.linters_by_ft or {}
            opts.linters_by_ft.sql = {}

            -- Set path to md linter config which is currently used by lazyvim.
            -- https://github.com/LazyVim/LazyVim/discussions/4094#discussioncomment-10178217
            opts.linters["markdownlint-cli2"] = {
                args = { "--config", vim.fn.expand("$HOME/.markdownlint-cli2.yaml"), "--" },
            }

            return opts
        end,
    },
    { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
