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

-- Disable arrow keys
vim.keymap.set("", "<Up>", "<nop>")
vim.keymap.set("", "<Down>", "<nop>")
vim.keymap.set("", "<Left>", "<nop>")
vim.keymap.set("", "<Right>", "<nop>")

local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Disable yank when do some operations.
-- Disable yank on delete
vim.keymap.set({ "n", "v" }, "d", '"_d', opts("Delete without yank"))
vim.keymap.set({ "n", "v" }, "D", '"_D', opts("Delete without yank"))

-- Remap exit modes to normal mode
vim.keymap.set({ "v", "i" }, "jf", "<ESC>", opts("Exit v|i to n mode"))

-- Movements
-- Unmap `h`
vim.keymap.set("", "h", "<nop>")

vim.keymap.set({ "n", "v" }, "l", "<Down>", opts("Move down"))
vim.keymap.set({ "n", "v" }, "k", "<Up>", opts("Move up"))
vim.keymap.set({ "n", "v" }, "j", "<Left>", opts("Move left"))
vim.keymap.set({ "n", "v" }, ";", "<Right>", opts("Move right"))

-- Panes management
-- Unmap default keybind to split windows
vim.keymap.set("", "<C-w>v", "<nop>")
vim.keymap.set("", "<C-w>s", "<nop>")
-- Switch panes
vim.keymap.set("n", "<C-w>l", "<C-w>j", opts("Switch to bottom pane"))
vim.keymap.set("n", "<C-w>k", "<C-w>k", opts("Switch to top pane"))
vim.keymap.set("n", "<C-w>;", "<C-w>l", opts("Switch to right pane"))
vim.keymap.set("n", "<C-w>j", "<C-w>h", opts("Switch to left pane"))

-- Buffers
vim.keymap.set("n", "t;", ":bnext<CR>", opts("Go to next buffer"))
vim.keymap.set("n", "tj", ":bprev<CR>", opts("Go to previous buffer"))
vim.keymap.set("n", "td", ":bdelete<CR>", opts("Close current buffer"))

-- Clear search highlights
vim.keymap.set("n", "<leader>h", ":nohl<CR>", opts("Clear search highlights"))

-- `spectre` keymaps
vim.keymap.set("n", "<leader>st", ':lua require("spectre").toggle()<CR>', opts("Toggle Spectre"))
vim.keymap.set(
    "n",
    "<leader>sf",
    ':lua require("spectre").open_file_search({select_word=true})<CR>',
    opts("Search on current file")
)

-- `conform` keymaps
vim.keymap.set(
    "n",
    "<leader>lf",
    ":lua require('conform').format({ async = true, lsp_fallback = true })<CR>",
    opts("Format buffer")
)
