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
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local lspconfig = require("lspconfig")

            -- Setup required language servers
            local servers = { "pyright", "lua_ls", "yamlls", "jsonls", "taplo" }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup({
                    capabilities = capabilities,
                })
            end

            -- Setup Diagnostic signs and highlight
            -- Docs: https://neovim.io/doc/user/diagnostic.html
            -- :help vim.diagnostic.config
            vim.diagnostic.config({
                virtual_text = { prefix = "●" }, -- Could be '●', '▎', 'x'
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

            -- Setup keymaps.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LocalLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local function opts(desc)
                        return { desc = desc, buffer = ev.buf, silent = true }
                    end

                    -- Show documentation for text under cursor
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Show definition preview hover"))

                    -- see available code actions, in visual mode will apply to selection
                    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Show code actions"))

                    -- Smart rename text below cursor inside current scope (indent guide).
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Smart rename in buffer"))

                    -- Show with Telescope
                    -- TODO: why its go to definitions instead of showing it?
                    -- To go back type: <ctrl> + o
                    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts("Show LSP definitions"))
                    -- Show all references for text below cursor in current workspace
                    vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts("Show LSP references"))

                    -- Show all diagnostics for opened buffer
                    vim.keymap.set(
                        "n",
                        "<leader>D",
                        "<cmd>Telescope diagnostics bufnr=0<CR>",
                        opts("Show buffer diagnostics")
                    )
                    -- Show diagnostics for current line
                    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts("Show line diagnostics"))

                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("Go to previous diagnostic")) -- jump to previous diagnostic in buffer
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("Go to next diagnostic")) -- jump to next diagnostic in buffer
                end,
            })
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
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
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
}
