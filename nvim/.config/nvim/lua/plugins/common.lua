return {
    {
        -- Library used by other plugins
        "nvim-lua/plenary.nvim",
        lazy = true,
    },
    { -- measure startuptime
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 10
        end,
    },
}
