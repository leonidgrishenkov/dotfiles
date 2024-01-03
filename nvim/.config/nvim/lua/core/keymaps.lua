-- Define the leader key for vim commands
vim.g.mapleader = " " -- use <space>

-- local options = { noremap = true, silent = true }
local keymap = vim.keymap

-- How it works
-- keymap.set(<mode, e.g. `i` for insert mode>, <target key/keys>, <action>)
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c"

-- Exit insert mode
keymap.set("i", "jf", "<ESC>") 

keymap.set("n", "l", "<Down>")
keymap.set("n", "j", "<Left>")
keymap.set("n", ";", "<Right>")

keymap.set("v", "l", "<Down>")
keymap.set("v", "j", "<Left>")
keymap.set("v", ";", "<Right>")

