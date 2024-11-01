return {
    {
        --- https://github.com/HiPhish/rainbow-delimiters.nvim
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            -- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
            -- This if taken from: https://github.com/yutkat/dotfiles/blob/main/.config/nvim/lua/rc/pluginlist.lua#L406
            if vim.fn.expand("%:p") ~= "" then
                vim.cmd.edit({ bang = true })
            end
        end,
    },
}
