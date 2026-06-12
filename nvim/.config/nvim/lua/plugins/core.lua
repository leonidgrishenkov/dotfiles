local icons = require("utils.icons")

return {
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin-nvim",
            icons = {
                diagnostics = icons.diagnostics,
                git = icons.git,
            },
        },
    },
}
