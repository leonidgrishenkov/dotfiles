return {
    -- Repo: https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-move.md
    -- Help: :h mini.move
    "echasnovski/mini.move",
    version = false,
    event = "VeryLazy",
    opts = {
        mappings = {
            -- Use "" (empty string) to disable one.
            -- Move visual selection in Visual mode.
            left = "H",
            right = "L",
            down = "J",
            up = "K",

            -- Move current line in Normal mode.
            line_left = "",
            line_right = "",
            line_down = "",
            line_up = "",
        },
    },
}
