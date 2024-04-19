return {
    {
        --[[
        Setup formatting diffrent sources with conform plugin.

        Repo: https://github.com/stevearc/conform.nvim
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
                    json = { { "prettierd", "prettier" } },
                    yaml = { { "prettierd", "prettier" } },
                    markdown = { { "prettierd", "prettier" } },
                    lua = { "stylua" },
                    sql = {
                        {
                            "sql_formatter", -- Repo: https://github.com/sql-formatter-org/sql-formatter
                            "sqlfluff", -- Repo: https://github.com/sqlfluff/sqlfluff
                        },
                    },
                    -- Dynamically determine formatter for python
                    python = function(bufnr)
                        if require("conform").get_formatter_info("ruff_format", bufnr).available then
                            return { "ruff_format" }
                        else
                            return { "isort", "black" }
                        end
                    end,
                    sh = { "shfmt" },
                    -- Use the "_" filetype to run formatters on filetypes that don't
                    -- have other formatters configured.
                    ["_"] = { "trim_whitespace" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    async = true,
                    timeout_ms = 1000,
                },
                -- Add extra options for formatters
                formatters = {
                    shfmt = {
                        prepend_args = { "-i", "2" },
                    },
                    -- TODO: This doesn't working. Google and fix
                    sql_formatter = {
                        prepend_args = { "--config", "$XDG_CONFIG_HOME/sql-formatter/config.json" },
                    },
                },
                -- Conform will notify you when a formatter errors
                notify_on_error = true,
            })
        end,
    },
}
