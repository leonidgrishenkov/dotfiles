--[[
Base keymappings for Neovim itself without plugins.

Plugins keymapping see in corresponding plugin file in lua/plugins/.

How to set new mapping:
    `vim.keymap.set({mode}, {lhs}, {rhs}, {opts})`

Where:
    {mode} (string or table) mode short-name
        "": Normal, Visual, Select, Operator-pending mode
        "n": Normal mode
        "v": Visual and Select mode
        "s": Select mode
        "x": Visual mode
        "o": Operator-pending mode
        "i": Insert mode
        "t": Terminal mode
        "!": Insert Insert and Command-line mode

    {lhs}: (string) left-hand side of the mapping, the keys we want to map
    {rhs}: (string or function) right-hand side of the mapping, the keys or function we want to execute after pressing {lhs}

    {opts}: (table) optional parameters
        silent: define a mapping that will not be echoed on the command line
        noremap: disable recursive mapping


Some usefull commands:
    :map <Keys> - Display existing mappings for keys. Example: :map <C-Left>
--]]

-- Define the leader key for vim commands
vim.g.mapleader = " " -- <space>
vim.g.maplocalleader = " "

-- Disable arrow keys
vim.keymap.set("", "<Up>", "<nop>")
vim.keymap.set("", "<Down>", "<nop>")
vim.keymap.set("", "<Left>", "<nop>")
vim.keymap.set("", "<Right>", "<nop>")

local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Clear search highlights
vim.keymap.set("n", "<leader>h", ":nohl<CR>", opts("HI: Clear all"))

-- =============== Yank ===============
-- Disable yank on delete word
vim.keymap.set({ "n", "v" }, "d", '"_d', opts(nil))
vim.keymap.set({ "n", "v" }, "D", '"_D', opts(nil))

-- Disable yank on delete symbol
vim.keymap.set({ "n", "v" }, "x", '"_x', opts(nil))
vim.keymap.set({ "n", "v" }, "X", '"_X', opts(nil))

-- Disable yank on paste operation
vim.keymap.set("x", "p", "P", opts(nil))

-- Remap exit modes to normal mode
vim.keymap.set({ "v", "i" }, "jf", "<ESC>", opts(nil))

-- =============== Windows ===============

-- Control window size
vim.keymap.set("n", "<leader>wk", ":resize +5<CR>", opts("Resize: horiz +5"))
vim.keymap.set("n", "<leader>wj", ":resize -5<CR>", opts("Resize: horiz -5"))
vim.keymap.set("n", "<leader>wh", ":vertical resize +5<CR>", opts("Resize: vertical +5"))
vim.keymap.set("n", "<leader>wl", ":vertical resize -5<CR>", opts("Resize: vertical -5"))

-- =============== Buffers ===============
vim.keymap.set("n", "tl", ":bnext<CR>", opts("Switch buf: next"))
vim.keymap.set("n", "th", ":bprev<CR>", opts("Switch buf: prev"))
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", opts("Close"))
vim.keymap.set("n", "<leader>ba", ":bufdo bd<CR>", opts("Close all"))

-- =============== Plugins ===============
-- 'spectre'
vim.keymap.set("n", "<leader>st", ':lua require("spectre").toggle()<CR>', opts("Spectre: toggle"))
vim.keymap.set(
    "n",
    "<leader>sf",
    ':lua require("spectre").open_file_search({select_word=true})<CR>',
    opts("Spectre: toggle on current file")
)

-- 'todo-comments'
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "TODO: go next" })

vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "TODO: go prev" })
