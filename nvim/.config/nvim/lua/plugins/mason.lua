return {
    {

        --[[
        Commands (To see all: :h mason-commands):
            :Mason - opens a graphical status window
            :MasonUpdate - updates all managed registries
            :MasonInstall <package> ... - installs/re-installs the provided packages
            :MasonUninstall <package> ... - uninstalls the provided packages
            :MasonUninstallAll - uninstalls all packages
            :MasonLog - opens the mason.nvim log file in a new tab window
        --]]
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        dependencies = {
            "williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
            "WhoIsSethDaniel/mason-tool-installer.nvim", -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
        },
        -- :h mason-settings
        config = function()
            -- import mason
            local mason = require("mason")

            -- import mason-lspconfig
            local mason_lspconfig = require("mason-lspconfig")

            local mason_tool_installer = require("mason-tool-installer")

            -- enable mason and configure icons
            mason.setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                    -- Add border for Mason window
                    border = "rounded",
                },
            })

            mason_lspconfig.setup({
                -- List of servers for mason to install
                ensure_installed = {
                    "lua_ls",
                    "pyright",
                    "ruff",
                    "yamlls",
                    "jsonls",
                    "taplo", -- LSP for toml files
                    -- "sqls", -- LSP for SQL
                    -- "terraformls",
                    "bashls",
                },
                -- auto-install configured servers (with lspconfig)
                automatic_installation = true, -- not the same as ensure_installed
            })

            mason_tool_installer.setup({
                -- Other tools for mason to install (linters, formatters etc.)
                ensure_installed = {
                    "stylua",
                    "prettier",
                    "sqlfluff",
                    "yamllint",
                    "shfmt",
                },
                auto_update = true,
                run_on_start = true,
            })
        end,
    },
}
