return {
    {
        --[[
        Search and replace in multiple files.

        Global keymaps are defined in `lua/config/keymaps.lua`.

        Repo: https://github.com/nvim-pack/nvim-spectre
        --]]
        "nvim-pack/nvim-spectre",
        lazy = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local spectre = require("spectre")

            -- Setup colorscheme palette for plugin highlights
            local theme = require("catppuccin.palettes").get_palette("frappe")
            vim.api.nvim_set_hl(0, "SpectreSearch", { bg = theme.red, fg = theme.base })
            vim.api.nvim_set_hl(0, "SpectreReplace", { bg = theme.green, fg = theme.base })

            -- Default settings: https://github.com/nvim-pack/nvim-spectre?tab=readme-ov-file#customization
            spectre.setup({
                highlight = {
                    search = "SpectreSearch",
                    replace = "SpectreReplace",
                },
            })
        end,
    },
}
