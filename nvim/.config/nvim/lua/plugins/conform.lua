return {
    {
        --[[
        Code formatting plugin. https://github.com/stevearc/conform.nvim

        To see info about attached client to current buffer: :ConformInfo
        --]]
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>lf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "n",
                desc = "Format current buffer",
            },
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
        ---@module "conform"
        ---@type conform.setupOpts
        opts = {
            log_level = vim.log.levels.WARN,
            formatters_by_ft = {
                -- All formatters: https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
                -- Use a sub-list to run only the first available formatter
                ["json"] = { "prettierd" },
                ["jsonc"] = { "prettierd" },
                ["yaml"] = { "prettierd" },
                -- ["yaml"] = function(bufnr)
                --     if require("conform").get_formatter_info("yamlfmt", bufnr).available then
                --         return { "yamlfmt" }
                --     else
                --         return { "prettierd" }
                --     end
                -- end,
                ["markdown"] = { "prettierd" },
                ["lua"] = { "stylua" },
                ["sql"] = { "sqlfluff" },
                ["sh"] = { "shfmt" },
                -- Use the "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                ["_"] = { "trim_whitespace" },
            },
            -- Extra options for formatters
            formatters = {
                shfmt = {
                    prepend_args = { "-i", "4", "--filename", "$FILENAME" },
                },
                sqlfluff = {
                    command = "sqlfluff",
                    args = { "format", "--stdin-filename", "$FILENAME", "-" },
                },
                yamlfmt = {
                    prepend_args = { "-conf", os.getenv("XDG_CONFIG_HOME") .. "/yamlfmt/.yamlfmt" },
                },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            -- Conform will notify you when a formatter errors
            notify_on_error = true,
            -- Conform will notify you when no formatters are available for the buffer
            notify_no_formatters = true,
        },
    },
}
