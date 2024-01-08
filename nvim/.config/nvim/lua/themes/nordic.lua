--[[
Nord-like theme

https://github.com/AlexvZyl/nordic.nvim
--]]
return {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[colorscheme nordic]])
    end,
}


