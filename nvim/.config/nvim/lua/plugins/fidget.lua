return {
    {
        -- UI for LSP progress, linting and formatting notifications.
        -- Repo: https://github.com/j-hui/fidget.nvim
        "j-hui/fidget.nvim",
        event = { "BufEnter" },
        config = function()
            -- Turn on LSP, formatting, and linting status and progress information
            require("fidget").setup({
                notification = {
                    window = {
                        -- Recommended by `catppuccin` theme.
                        winblend = 0,
                    },
                },
            })
        end,
    },
}
