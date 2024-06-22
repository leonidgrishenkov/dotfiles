return {
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-move.md
    -- Doc: `:h mini.move`
    "echasnovski/mini.move",
    version = false,
    config = function()
        require("mini.move").setup({
            mappings = {
                -- Use "" (empty string) to disable one.
                -- Move visual selection in Visual mode.
                left = "J",
                right = ":",
                down = "L",
                up = "K",

                -- Move current line in Normal mode.
                line_left = "",
                line_right = "",
                line_down = "",
                line_up = "",
            },
        })
    end,
}
