return {
    {
        --[[
        Plugin for linting. https://github.com/mfussenegger/nvim-lint
        --]]
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                -- https://github.com/adrienverge/yamllint
                ["yaml"] = { "yamllint" },
                -- https://github.com/sqlfluff/sqlfluff
                -- TODO: Create and use here config file for sqlfluff
                ["sql"] = { "sqlfluff" },
                ["python"] = { "mypy" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            -- TODO: Read more about event types. Maybe here we need to add a couple more events
            -- because not linter reapplyied only on save.
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            -- vim.keymap.set("n", "<leader>l", function()
            --     lint.try_lint()
            -- end, { desc = "Trigger linting for current file" })
        end,
    },
}
