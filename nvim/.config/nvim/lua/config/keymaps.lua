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

--]]

-- Define the leader key for vim commands
vim.g.mapleader = " " -- <space>
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- Disable arrow keys
keymap.set("", "<Up>", "<nop>")
keymap.set("", "<Down>", "<nop>")
keymap.set("", "<Left>", "<nop>")
keymap.set("", "<Right>", "<nop>")

local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Disable yank when do some operations.
-- Disable yank on delete
keymap.set({ "n", "v" }, "d", '"_d', opts("Delete w/o yank"))
keymap.set({ "n", "v" }, "D", '"_D', opts("Delete w/o yank"))

-- Remap exit modes to normal mode
keymap.set({ "v", "i" }, "jf", "<ESC>", opts("Exit v|i to n mode"))

-- Movements
-- Unmap `h`  TODO: is it work?
keymap.set("", "h", "<nop>")

keymap.set({ "n", "v" }, "l", "<Down>", opts("Move down"))
keymap.set({ "n", "v" }, "k", "<Up>", opts("Move up"))
keymap.set({ "n", "v" }, "j", "<Left>", opts("Move left"))
keymap.set({ "n", "v" }, ";", "<Right>", opts("Move right"))

-- Close all windows and exit
-- keymap.set("n", "<leader>q", ":q<CR>", opts("Close all and exit as `:q`")) -- <leader-key> + <q>

-- Panes createion (Window split)
-- Split window vertically. Command line:`:vsplit`
keymap.set("n", "<leader>V", "<C-w>v", opts("Split window vertically"))
-- Split window horizontally. Command: `:split`
keymap.set("n", "<leader>H", "<C-w>s", opts("Split window horizontally"))

-- Switch panes
keymap.set("n", "<leader>j", "<C-w>h", opts("Switch pane left"))
keymap.set("n", "<leader>l", "<C-w>j", opts("Switch to down"))
keymap.set("n", "<leader>k", "<C-w>k", opts("Switch to up"))
keymap.set("n", "<leader>;", "<C-w>l", opts("Switch to right"))

-- Manipulate tabs
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", opts("Open new tab")) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", opts("Close current tab")) -- close current tab
keymap.set("n", "<leader>]", "<cmd>tabn<CR>", opts("Go to next tab")) --  go to next tab
keymap.set("n", "<leader>[", "<cmd>tabp<CR>", opts("Go to previous tab")) --  go to previous tab
keymap.set("n", "<leader>tm", "<cmd>tabnew %<CR>", opts("Open current buffer in new tab")) --  move current buffer to new tab

-- Clear search highlights
keymap.set("n", "<leader>ch", ":nohl<CR>", opts("Clear search highlights"))

-- -- Move block
-- keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Block Down" })
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Block Up" })

-- -- close buffer
-- keymap.set("n", "<leader>q", "<cmd>bd<CR>", { desc = "Close Buffer" })

-- `spectre` keymaps
vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "spectre: Toggle Spectre",
})
-- vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
--     desc = "Search current word",
-- })
-- vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
--     desc = "Search current word",
-- })
-- vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
--     desc = "Search on current file",
-- })
