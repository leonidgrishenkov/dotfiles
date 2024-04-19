return {
    {
        --[[
        Configurations for LSP.

        Repo: https://github.com/neovim/nvim-lspconfig
        Wiki: https://github.com/neovim/nvim-lspconfig/wiki

        :LspInfo
        ]]
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- https://github.com/microsoft/pyright
            lspconfig.pyright.setup({})
            lspconfig.lua_ls.setup({})
            lspconfig.yamlls.setup({})
            lspconfig.jsonls.setup({})
            lspconfig.taplo.setup({})

            -- Change the Diagnostic symbols in the sign column (gutter)
            local signs = {
                Error = "",
                Warn = "",
                Hint = "",
                Info = "",
            }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end
        end,
    },
    {

        --[[
        :h mason-commands

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
                },
            })

            mason_lspconfig.setup({
                -- list of servers for mason to install
                ensure_installed = {
                    "lua_ls",
                    "pyright",
                    "yamlls",
                    "jsonls",
                    "taplo", -- LSP for toml files
                },
                -- auto-install configured servers (with lspconfig)
                automatic_installation = true, -- not the same as ensure_installed
            })

            mason_tool_installer.setup({
                ensure_installed = {
                    "stylua", -- lua formatter
                    "ruff", -- python formatter and linter
                    "prettierd",
                    "prettier",
                    "sql-formatter",
                    "sqlfluff",
                    "stylua",
                    "shfmt",
                },
                auto_update = true,
                run_on_start = true,
            })
        end,
    },
}
