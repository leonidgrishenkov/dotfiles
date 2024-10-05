return {
    {
        --- https://github.com/MeanderingProgrammer/render-markdown.nvim
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
        config = function()
            -- https://github.com/MeanderingProgrammer/render-markdown.nvim?tab=readme-ov-file#setup
            require("render-markdown").setup({
                heading = { sign = true },
                code = { sign = false, style = "language" },
            })
        end,
    },
}
