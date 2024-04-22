return {
    {
        --[[
        Configurations for LSP.

        Repo: https://github.com/neovim/nvim-lspconfig
        Wiki: https://github.com/neovim/nvim-lspconfig/wiki

        :LspInfo
        To restart plugin: :LspRestart
        ]]
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "folke/neodev.nvim", opts = {} }, -- will improve lua_ls functionality
            -- Add ops on files such as rename imports if file name was changed
            { "antosha417/nvim-lsp-file-operations", config = true },
        },
        config = function()
            local lspconfig = require("lspconfig")

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- On attach keymaps. When plugin connected to LSP server.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf, silent = true }

                    -- Show documentation for text under cursor
                    opts.desc = "Show definition preview hover"
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

                    -- see available code actions, in visual mode will apply to selection
                    opts.desc = "Show code actions"
                    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                    -- Smart rename text below cursor inside current scope (indent guide).
                    opts.desc = "Smart rename in buffer"
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                    -- Show with Telescope
                    -- To go back type: <ctrl> + o
                    opts.desc = "Go to LSP definition"
                    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
                    -- Show all references for text below cursor in current workspace
                    opts.desc = "Show all LSP references"
                    vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

                    -- Show all diagnostics for opened buffer
                    opts.desc = "Show buffer diagnostics"
                    vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
                    -- Show diagnostics for current line
                    opts.desc = "Show line diagnostics"
                    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

                    opts.desc = "Jump to previous diagnostic"
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                    opts.desc = "Jump to next diagnostic"
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                end,
            })

            -- Setup required language servers
            -- LSP for python
            lspconfig["pyright"].setup({
                capabilities = capabilities,
            })

            -- LSP for lua
            lspconfig["lua_ls"].setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        -- make the language server recognize "vim" global
                        diagnostics = {
                            globals = { "vim" },
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            })

            -- LSP for yaml
            lspconfig["yamlls"].setup({
                capabilities = capabilities,
            })

            -- LSP for json
            lspconfig["jsonls"].setup({
                capabilities = capabilities,
            })

            -- LSP for toml
            lspconfig["taplo"].setup({
                capabilities = capabilities,
            })

            -- Setup Diagnostic signs and highlight
            -- Docs: https://neovim.io/doc/user/diagnostic.html
            -- :help vim.diagnostic.config
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    spacing = 4,
                    source = "if_many",
                },
                signs = true, -- Show symbols in sign column (gutter)
                underline = false, -- Underline problem line
                update_in_insert = false,
                severity_sort = false,
            })

            -- Setup symbols in the sign column (gutter)
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
                    "shfmt",
                },
                auto_update = true,
                run_on_start = true,
            })
        end,
    },
    {
        --[[
        Repo: https://github.com/mfussenegger/nvim-lint
        --]]
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                python = { "ruff" },
                yaml = { "yamllint" },
                sql = { "sqlfluff" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },
}
