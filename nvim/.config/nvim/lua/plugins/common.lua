return {
    {
        -- Library used by other plugins
        "nvim-lua/plenary.nvim",
        lazy = true,
    },
    {
        -- Measure startuptime
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        init = function()
            vim.g.startuptime_tries = 10
        end,
    },
}
