return {
    {
        -- Repo: https://github.com/catppuccin/nvim
        -- Docs: `:h catppuccin`
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "frappe", -- Can be one of: latte, frappe, macchiato, mocha
                transparent_background = true,
                term_colors = true,
                show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
                styles = {
                    -- To see all available values: `:h highlight-args`
                    comments = {},
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                -- About integrations: https://github.com/catppuccin/nvim#integrations
                integrations = {
                    nvimtree = true,
                    cmp = true,
                    treesitter = true,
                },
            })
        end,
        init = function()
            vim.cmd("colorscheme catppuccin")
        end,
    },
}
