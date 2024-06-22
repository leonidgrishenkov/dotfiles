return {
    {
        -- https://github.com/SmiteshP/nvim-navic
        "SmiteshP/nvim-navic",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("nvim-navic").setup({
                lsp = {
                    auto_attach = true,
                },
            })
        end,
    },
    {
        -- https://github.com/utilyre/barbecue.nvim
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("barbecue").setup({
                theme = "catppuccin",
            })
        end,
    },
}
