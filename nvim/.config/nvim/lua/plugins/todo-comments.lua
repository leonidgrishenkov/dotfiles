return {
    {
        --[[
        Highlights comments contains words such todo, fix, warn etc.

        Repo: https://github.com/folke/todo-comments.nvim

        Docs: :h todo-comments.nvim
        --]]
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- Default config: https://github.com/folke/todo-comments.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
            signs = true, -- show icons in the signs column
            sign_priority = 2,
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
                multiline = false, -- enable multine todo comments
                before = "", -- "fg" or "bg" or empty
                keyword = "fg", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                after = "", -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
                comments_only = true, -- uses treesitter to match keywords in comments only
                max_line_len = 400, -- ignore lines longer than this
                exclude = {}, -- list of file types to exclude highlighting
            },
            -- regex that will be used to match keywords.
            -- don't replace the (KEYWORDS) placeholder
            pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        },
    },
}
