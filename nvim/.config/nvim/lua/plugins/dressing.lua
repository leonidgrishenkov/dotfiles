return {
    {
        --[[
        That plugin improves UI and enables telescope plugin
        for two neovim builtin functions: `vim.ui.select()` and `vim.ui.input()`.
        When one of that functions called from any plugin improved version will be shown.

        Repo: https://github.com/stevearc/dressing.nvim

        Docs: :h dressing-configuration
        --]]
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        config = function()
            require("dressing").setup({})
        end,
    },
}
