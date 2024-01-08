--[[
Keybingins for Neovim and it's plugins
--]]

-- Define the leader key for vim commands
vim.g.mapleader = " " -- <space>

-- local options = { noremap = true, silent = true }
local keymap = vim.keymap

-- How it works
-- keymap.set(<mode, e.g. `i` for insert mode>, <target key/keys>, <action>, <options>)
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c"

--[[
Keybingins for Neovim
--]]

-- Disable arrow keys
keymap.set('', '<up>', '<nop>')
keymap.set('', '<down>', '<nop>')
keymap.set('', '<left>', '<nop>')
keymap.set('', '<right>', '<nop>')

-- Exit insert mode to normal
keymap.set("i", "jf", "<ESC>", { desc = "Exit insert mode with `jf`" }) 
keymap.set("v", "jf", "<ESC>", { desc = "Exit visual mode with `jf`" }) 

-- Movements
keymap.set("n", "l", "<Down>")
keymap.set("v", "l", "<Down>")

keymap.set("n", "j", "<Left>")
keymap.set("v", "j", "<Left>")

keymap.set("n", ";", "<Right>")
keymap.set("v", ";", "<Right>")

-- Close all windows and exit
keymap.set('n', '<leader>q', ':q!<CR>') -- <leader-key> + <q>


--[[
Keymap for plugins
--]]
-- `nvim-tree`
keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
-- keymap.set("n", "<CMD-e>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
