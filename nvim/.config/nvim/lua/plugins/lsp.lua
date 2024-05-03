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
            local icons = require("utils.icons").diagnostics

            -- On attach keymaps. When plugin connected to LSP server.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf, silent = true }

                    -- Show documentation for text under cursor
                    opts.desc = "Show definition preview of word"
                    vim.keymap.set("n", "<leader>lp", vim.lsp.buf.hover, opts)

                    -- see available code actions, in visual mode will apply to selection
                    -- opts.desc = "Show code actions"
                    -- vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                    -- Smart rename text below cursor inside current scope (indent guide).
                    -- TODO: Maybe change this keymap to single char?
                    opts.desc = "Rename word in buffer"
                    vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, opts)

                    -- Telescope
                    -- To go back type: <ctrl> + o
                    -- TODO: Is there any method to show definition in preview?
                    opts.desc = "Show definitions of word"
                    vim.keymap.set("n", "<leader>ld", ":Telescope lsp_definitions jump_type=never<CR>", opts)

                    opts.desc = "Show references of word"
                    vim.keymap.set("n", "<leader>lr", ":Telescope lsp_references<CR>", opts)

                    opts.desc = "Search in buffer diagnostics"
                    vim.keymap.set("n", "<leader>fd", ":Telescope diagnostics bufnr=0<CR>", opts)

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
                -- lazy-load schemastore when needed
                on_new_config = function(new_config)
                    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                    vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
                end,
                settings = {
                    json = {
                        format = {
                            enable = true,
                        },
                        validate = { enable = true },
                    },
                },
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
                Error = icons.Error,
                Warn = icons.Warn,
                Hint = icons.Hint,
                Info = icons.Info,
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
}
