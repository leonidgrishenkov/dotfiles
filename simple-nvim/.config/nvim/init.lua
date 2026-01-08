vim.opt.syntax = "ON"
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.cursorlineopt = "number" -- highlight the line number

-- Escape with 'jf' in insert and visual mode
vim.keymap.set('i', 'jf', '<Esc>')
vim.keymap.set('v', 'jf', '<Esc>')

-- Clipboard integration (uses system clipboard)
vim.opt.clipboard = "unnamedplus"

-- Indentation settings
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.tabstop = 4         -- Number of spaces tabs count for
vim.opt.shiftwidth = 4      -- Number of spaces for autoindent
vim.opt.softtabstop = 4     -- Number of spaces per Tab

vim.opt.conceallevel = 0

local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Remap exit modes to normal mode
vim.keymap.set({ "v", "i" }, "jf", "<ESC>", opts(nil))
