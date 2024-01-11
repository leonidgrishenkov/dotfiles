--[[
General configurations.

All options:
    `:h options`
--]]

-- Global variables
local g = vim.g
-- Set options (global/buffer/windows-scoped)
local opt = vim.opt

-- General
opt.mouse = "a" -- Enable mouse support
opt.mousemoveevent = true -- ?
-- Learn about `modeline`
-- opt.modeline = true

-- https://neovim.io/doc/user/provider.html#provider-clipboard
opt.clipboard = "unnamed" -- Copy/paste to system clipboard

-- Is that specified in plugin setup?
-- opt.completeopt = "menuone,noinsert,noselect" -- Autocomplete options

opt.swapfile = false -- Don't use swapfile
opt.backup = false -- Creates a backup file
opt.undofile = true -- Enable/disable persistent undo
opt.writebackup = false -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.fileencoding = "utf-8" -- The encoding written to a file

-- UI
opt.termguicolors = true -- Enable 24-bit RGB colors
g.termguicolors = true
opt.background = "dark"
opt.showmode = false -- Don't show modes, e.g. -- INSERT --
opt.pumheight = 10 -- Pop up menu height
opt.laststatus = 3 -- Set global statusline
opt.showmatch = true -- Highlight matching parenthesis
opt.foldmethod = "marker" -- Enable folding (default 'foldmarker')
-- opt.colorcolumn = '80' -- Line lenght marker at 80 columns
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom
opt.guifont = "MesloLGM Nerd Font:h15"
g.guifont = "MesloLGM Nerd Font:h15"

-- Line numbers
opt.relativenumber = true -- Show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.numberwidth = 2 -- set number column width

-- Cursor
opt.cursorline = true -- highlight the current line
opt.cursorlineopt = "number" -- What to highlight
opt.cursorcolumn = false -- highlight current cursor column

-- Line wrapping
opt.wrap = false -- display lines as one long line
opt.linebreak = true -- companion to wrap, don't split words

-- Tabs & indentation
opt.expandtab = true -- Convert tab to spaces
opt.shiftwidth = 4 -- Spaces for indent width
opt.tabstop = 4 -- 1 tab == 4 spaces
opt.smartindent = true -- Autoindent new lines
opt.autoindent = true -- Copy indent from current line when starting new one

-- Search
opt.hlsearch = false -- Highlight all matches on previous search pattern
opt.incsearch = true
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true -- Ignore lowercase for the whole pattern

-- Memory and CPU
opt.hidden = true -- Enable background buffers
opt.history = 100 -- Remember N lines in history
opt.lazyredraw = true -- Faster scrolling
opt.synmaxcol = 240 -- Max column for syntax highlight
opt.updatetime = 250 -- ms to wait for trigger an event (4000ms default)
opt.timeoutlen = 300 -- ?
