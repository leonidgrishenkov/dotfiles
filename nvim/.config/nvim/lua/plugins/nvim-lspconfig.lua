---@diagnostic disable: unused-local

return {
    {
        --[[
        Configurations for LSP.

        Repo: https://github.com/neovim/nvim-lspconfig
        Wiki: https://github.com/neovim/nvim-lspconfig/wiki

        Commands:
            :LspInfo - Shows info about lsp server attached to current buffer.
            :LspRestart - Restarts entire plugin.
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
            -- Some servers complain if not provided (e.g., yamlls)
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }
            local icons = require("utils.icons").diagnostics

            -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
            -- Enable border for LspInfo window
            -- TODO: This is not working anymore. Find some workarround.
            -- require("lspconfig.ui.windows").default_options.border = "single"

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

                    -- See available code actions, in visual mode will apply to selection
                    opts.desc = "Show code actions"
                    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)

                    -- Smart rename text below cursor inside current scope (indent guide).
                    opts.desc = "Rename word in buffer"
                    vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, opts)

                    -- Telescope
                    -- To go back type: <ctrl> + o
                    -- TODO: Is there any method to show definition in preview?
                    opts.desc = "Show definition of word"
                    vim.keymap.set("n", "<leader>lD", ":Telescope lsp_definitions jump_type=never<CR>", opts)
                    opts.desc = "Go to definition of word"
                    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)

                    opts.desc = "Show references of word"
                    vim.keymap.set("n", "<leader>lr", ":Telescope lsp_references<CR>", opts)

                    opts.desc = "Search in buffer diagnostics"
                    vim.keymap.set("n", "<leader>fd", ":Telescope diagnostics bufnr=0<CR>", opts)

                    -- Show diagnostics for current line
                    opts.desc = "Show line diagnostics"
                    vim.keymap.set("n", "<leader>xl", vim.diagnostic.open_float, opts)

                    opts.desc = "Jump to previous diagnostic"
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                    opts.desc = "Jump to next diagnostic"
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                end,
            })

            -- Setup required language servers.
            -- Docs about servers configurations: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            --
            -- Pyright as LSP and static type checker for python.
            -- https://microsoft.github.io/pyright/#/settings?id=pyright-settings
            lspconfig["pyright"].setup({
                capabilities = capabilities,
                filetypes = { "python" },
                settings = {
                    pyright = {
                        -- Disable organize imports in favor of Ruff.
                        disableOrganizeImports = true,
                    },
                    python = {
                        analysis = {
                            -- Ignore all files for analysis to exclusively use Ruff for linting.
                            -- ignore = { "*" },
                            -- Determines the default type-checking level used by pyright.
                            -- Could be one of: "off", "basic", "standard" or "strict"
                            typeCheckingMode = "basic",
                            -- Determines whether pyright offers auto-import completions.
                            autoImportCompletions = false,
                            -- Determines whether pyright automatically adds common search paths like "src"
                            -- if there are no execution environments defined in the config file.
                            -- autoSearchPaths = true,
                            -- Determines whether pyright analyzes (and reports errors for) all files in the workspace,
                            -- as indicated by the config file. If this option is set to "openFilesOnly", pyright analyzes only open files.
                            diagnosticMode = "openFilesOnly",
                            -- useLibraryCodeForTypes = true,
                            -- Mapping with duagnostic settings overrides.
                            -- https://microsoft.github.io/pyright/#/configuration?id=type-check-diagnostics-settings
                            diagnosticSeverityOverrides = {
                                reportMissingImports = "error",
                            },
                        },
                    },
                },
            })

            -- Ruff as linter and formatter for python.
            -- NOTE: Now ruff language server is include in main ruff binary.
            -- That's why here I use just 'ruff' instead of deprecated 'ruff_lsp'.
            -- See: https://docs.astral.sh/ruff/editors/
            -- Neovim setup: https://docs.astral.sh/ruff/editors/setup/#neovim
            lspconfig["ruff"].setup({
                cmd = { "ruff", "server" },
                filetypes = { "python" },
                on_attach = function(client, bufnr)
                    -- Disable `textDocument/hover` in favor of Pyright
                    if client.name == "ruff" then
                        client.server_capabilities.hoverProvider = false
                    end
                end,
                -- Configure `ruff`.
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ruff_lsp
                -- For the default config, along with instructions on how to customize the settings
                init_options = {
                    settings = {
                        configuration = os.getenv("XDG_CONFIG_HOME") .. "/ruff/ruff.toml",
                        -- Any extra CLI arguments for `ruff` go here.
                        -- args = { "--config", os.getenv("XDG_CONFIG_HOME") .. "/ruff/ruff.toml" },
                    },
                },
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
                settings = {
                    yaml = {
                        keyOrdering = false,
                    },
                },
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

            -- LSP for SQL
            -- lspconfig["sqls"].setup({
            --     capabilities = capabilities,
            -- })

            -- LSP for Terraform
            -- https://github.com/hashicorp/terraform-ls
            -- Usage: https://github.com/hashicorp/terraform-ls/blob/main/docs/USAGE.md
            lspconfig["terraformls"].setup({
                capabilities = capabilities,
            })

            -- LSP for Bash.
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#bashls
            lspconfig["bashls"].setup({
                capabilities = capabilities,
                filetypes = { "bash", "sh", "zsh" },
            })

            -- Setup Diagnostic signs and highlight
            -- Docs: https://neovim.io/doc/user/diagnostic.html
            -- :help vim.diagnostic.config
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "",
                    spacing = 2,
                    source = false,
                    format = function(diagnostic)
                        if diagnostic.severity == vim.diagnostic.severity.ERROR then
                            return string.format("%s %s", icons.Error, diagnostic.message)
                        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
                            return string.format("%s %s", icons.Warn, diagnostic.message)
                        elseif diagnostic.severity == vim.diagnostic.severity.HINT then
                            return string.format("%s %s", icons.Hint, diagnostic.message)
                        end
                        return diagnostic.message
                    end,
                },
                signs = true, -- Show symbols in sign column (gutter)
                underline = true, -- Underline problem line
                update_in_insert = true,
                severity_sort = true,
                float = {
                    source = true,
                },
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
}
