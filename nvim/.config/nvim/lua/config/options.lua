--[[
General configurations.

Help: :h options
--]]

-- `vim.g` - Global options
-- `vim.opt` - Set options (global/buffer/windows-scoped)

-- recommended settings from `nvim-tree` documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- General
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.mousemoveevent = true -- ?
vim.opt.mousefocus = true -- ?
-- Learn about `modeline`
-- opt.modeline = true

-- Enable LazyVim auto format.
-- What does it do?
-- https://www.lazyvim.org/configuration/general
-- g.autoformat = true

-- https://neovim.io/doc/user/provider.html#provider-clipboard
-- `unnamedplus` - Sync with system clipboard
vim.opt.clipboard = "unnamed,unnamedplus"

vim.opt.swapfile = false -- Don't use swapfile
vim.opt.backup = false -- Creates a backup file
vim.opt.undofile = true -- Enable/disable persistent undo
-- If a file is being edited by another program (or was written to file while editing with another program),
-- it is not allowed to be edited
vim.opt.writebackup = false
vim.opt.fileencoding = "utf-8" -- The encoding written to a file

-- UI
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.g.termguicolors = true -- TODO: Does this work?

-- opt.cmdheight = 0 -- ?

vim.opt.background = "dark"
vim.opt.showmode = false -- Don't show modes, e.g. -- INSERT --
vim.opt.pumheight = 10 -- Pop up menu height
vim.opt.laststatus = 3 -- Set global statusline
vim.opt.showmatch = true -- Highlight matching parenthesis
-- opt.colorcolumn = '80' -- Line lenght marker at 80 columns
vim.opt.guifont = "MesloLGM Nerd Font:h15" -- ?
vim.g.guifont = "MesloLGM Nerd Font:h15" -- ?

-- Setup Singcolumn size.
-- See :h options for defails.
vim.opt.signcolumn = "auto:3"

-- Line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)
vim.opt.numberwidth = 1 -- set number column width

-- Cursor
vim.opt.cursorline = true -- highlight the current line
vim.opt.cursorlineopt = "number" -- What to highlight
vim.opt.cursorcolumn = false -- highlight current cursor column
vim.opt.guicursor = "n-v-c:block-blinkon200,i:ver25-blinkon200" -- cursor styling

-- Line wrapping
vim.opt.wrap = false -- display lines as one long line
-- opt.linebreak = true  -- ?
vim.opt.sidescroll = 8 -- Columns of context
-- opt.listchars+=precedes:<,extends:>
-- Number of lines to keep if this is an up or down border
vim.opt.scrolloff = 4

-- Visiable line in editor which indicates end of line
-- vim.opt.colorcolumn = "120"

-- split windows
vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

vim.opt.spelllang = { "en" }
vim.opt.splitkeep = "screen"
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
-- opt.winminwidth = 5 -- Minimum window width

-- opt.wildmenu = true
-- opt.wildmode = "longest:full,full" -- Command-line completion mode

-- Tabs & indentation
vim.opt.expandtab = true -- Convert tab to spaces
vim.opt.shiftwidth = 4 -- Spaces for indent width
vim.opt.tabstop = 4 -- 1 tab == 4 spaces
vim.opt.smartindent = true -- Autoindent new lines
vim.opt.autoindent = true -- Copy indent from current line when starting new one

vim.opt.shiftround = true -- Round indent

-- Search
vim.opt.hlsearch = true -- Highlight all matches on previous search pattern
vim.opt.incsearch = true
vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true -- Ignore lowercase for the whole pattern

-- Memory and CPU
vim.opt.hidden = true -- Enable background buffers
vim.opt.history = 100 -- Remember N lines in history
vim.opt.lazyredraw = false -- Faster scrolling
vim.opt.synmaxcol = 240 -- Max column for syntax highlight
vim.opt.updatetime = 250 -- ms to wait for trigger an event (4000ms default)
vim.opt.timeoutlen = 300 -- ?

-- opt.conceallevel = 3 -- Hide * markup for bold and italic TODO: how it works?
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer

-- opt.pumblend = 10 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of entries in a popup
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.formatoptions = "jcroqlnt" -- tcqj

-- Folding.
-- For keymaps see docs: :h fold opening and closing folds
-- vim.opt.foldmethod = "indent" -- folds will be autodefined based on indents
-- Recommended for `nvim-ufo` plugin: https://github.com/kevinhwang91/nvim-ufo?tab=readme-ov-file#minimal-configuration
vim.o.foldcolumn = "0" -- Show fold infos in signcolomn
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- opt.foldtext = " " -- ?

-- Characters to fill the statuslines, vertical separators and special
-- lines in the window.
vim.opt.fillchars = {
    vert = "│",
    -- fold = "⠀",
    eob = " ", -- suppress ~ at EndOfBuffer
    -- diff = "⣿", -- alternatives = ⣿ ░ ─ ╱
    msgsep = "‾",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
}

-- Fix markdown indentation settings
-- vim.g.markdown_recommended_style = 0
