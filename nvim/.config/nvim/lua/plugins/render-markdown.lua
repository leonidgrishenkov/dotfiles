return {
    {
        --- https://github.com/MeanderingProgrammer/render-markdown.nvim
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        enabled = false,
        config = function()
            -- https://github.com/MeanderingProgrammer/render-markdown.nvim?tab=readme-ov-file#setup
            require("render-markdown").setup({
                heading = { sign = true, width = "full" },
                code = { enabled = true, render_modes = true, sign = false, style = "full", width = "full" },
            })
        end,
    },
}
