return {
    {
        -- Repo: https://github.com/echasnovski/mini.comment
        "echasnovski/mini.comment",
        event = "VeryLazy",
        version = "*", -- Stable releases
        opts = {
            options = {
                -- Whether to ignore blank lines when commenting
                ignore_blank_line = true,
                -- Whether to force single space inner padding for comment parts
                pad_comment_parts = true,
            },
            mappings = {
                -- Toggle comment on current line
                comment_line = "<leader>cl",

                -- Toggle comment on visual selection
                comment_visual = "<leader>cl",
            },
        },
    },
}
