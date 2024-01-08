--[[
Nord-like theme.
Repo:
    https://github.com/AlexvZyl/nordic.nvim
Docs:
    `:h nordic`
--]]
return {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        nordic = require('nordic')

        nordic.setup({
            italic_comments = false,
            transparent_bg = true,
            cursorline = {
                bold = false,
                bold_number = true,
            },
            noice = {
                style = 'flat',
            },
        })
        -- Activate theme
        nordic.load() 
    end,
}
