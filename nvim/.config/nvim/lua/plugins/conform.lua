return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                yaml = { "yamlfmt" },
            },
            formatters = {
                sqlfluff = {
                    -- Pass --FIX-EVEN-UNPARSABLE and --ignore=templating explicitly so sqlfluff formats the file
                    -- even when template variables (like jinja params, macros, etc.) cannot be resolved at lint time.
                    args = { "fix", "--FIX-EVEN-UNPARSABLE", "--ignore=templating", "-" },
                },
            },
        },
    },
}
