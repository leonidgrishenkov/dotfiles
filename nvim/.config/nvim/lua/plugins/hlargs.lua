return {
    {
        -- https://github.com/m-demare/hlargs.nvim
        "m-demare/hlargs.nvim",
        config = function()
            require("hlargs").setup({
                color = '#d4b4ce', -- HEX color. Default: #ef9062
            })
        end,
    },
}
