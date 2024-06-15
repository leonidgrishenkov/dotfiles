return {
    {
        --[[
        Code formatting plugin. https://github.com/stevearc/conform.nvim

        To see info about attached client to current buffer: :ConformInfo
        --]]
        "stevearc/conform.nvim",
        lazy = true,
        dependencies = { "mason.nvim" },
        event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
        config = function()
            local conform = require("conform")

            -- TODO: Find and setup formatter for toml file. Maybe taplo?
            conform.setup({
                formatters_by_ft = {
                    -- All formatters: https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
                    -- Use a sub-list to run only the first available formatter
                    ["json"] = { "prettier" },
                    ["jsonc"] = { "prettier" },
                    ["yaml"] = { "prettier" },
                    ["markdown"] = { "prettier" },
                    ["lua"] = { "stylua" },
                    ["sql"] = {
                        {
                            "sql_formatter", -- Repo: https://github.com/sql-formatter-org/sql-formatter
                            -- "sqlfluff", -- Repo: https://github.com/sqlfluff/sqlfluff
                        },
                    },
                    ["sh"] = { "shfmt" },
                    -- Use the "_" filetype to run formatters on filetypes that don't
                    -- have other formatters configured.
                    ["_"] = { "trim_whitespace" },
                },
                -- Autoformat on save option.
                -- format_on_save = {
                --     lsp_fallback = true,
                --     async = false,
                --     timeout_ms = 1000,
                -- },
                -- Add extra options for formatters
                formatters = {
                    shfmt = {
                        prepend_args = { "-i", "2" },
                    },
                    sql_formatter = {
                        prepend_args = {
                            "--config",
                            os.getenv("HOME") .. "/Code/configs/sql-formatter/.config/sql-formatter/config.json",
                        },
                    },
                    prettier = {
                        prepend_args = { "--tab-width", "4", "--use-tabs", "true" },
                    },
                },
                -- Conform will notify you when a formatter errors
                notify_on_error = true,
            })
        end,
    },
}
