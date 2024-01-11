--[[
General configurations.

All options:
    `:h options`
--]]

-- Global variables
local g = vim.g
-- Set options (global/buffer/windows-scoped)
local opt = vim.opt

-- recommended settings from `nvim-tree` documentation
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- General
opt.mouse = "a" -- Enable mouse support
opt.mousemoveevent = true -- ?
-- Learn about `modeline`
-- opt.modeline = true

-- Enable LazyVim auto format.
-- What does it do?
-- https://www.lazyvim.org/configuration/general
-- g.autoformat = true

-- https://neovim.io/doc/user/provider.html#provider-clipboard
-- `unnamedplus` - Sync with system clipboard
opt.clipboard = "unnamedplus"

-- Autocomplete options for vim command line mode (in `:` when you press <Tab>)
opt.completeopt = "menuone,noinsert,noselect"

opt.swapfile = false -- Don't use swapfile
opt.backup = false -- Creates a backup file
opt.undofile = true -- Enable/disable persistent undo
opt.writebackup = false -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.fileencoding = "utf-8" -- The encoding written to a file

-- UI
opt.termguicolors = true -- Enable 24-bit RGB colors
g.termguicolors = true

-- opt.cmdheight = 0 -- ?
-- opt.guicursor = "" -- disable cursor-styling

opt.background = "dark"
opt.showmode = false -- Don't show modes, e.g. -- INSERT --
opt.pumheight = 10 -- Pop up menu height
opt.laststatus = 3 -- Set global statusline
opt.showmatch = true -- Highlight matching parenthesis
opt.foldmethod = "marker" -- Enable folding (default 'foldmarker')
-- opt.colorcolumn = '80' -- Line lenght marker at 80 columns
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom
opt.guifont = "MesloLGM Nerd Font:h15" -- ?
g.guifont = "MesloLGM Nerd Font:h15" -- ?
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

-- Line numbers
opt.relativenumber = true -- Show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.numberwidth = 1 -- set number column width

-- Cursor
opt.cursorline = true -- highlight the current line
opt.cursorlineopt = "number" -- What to highlight
opt.cursorcolumn = false -- highlight current cursor column

-- Line wrapping
opt.wrap = false -- display lines as one long line
-- opt.linebreak = true  -- ?
opt.sidescroll = 8 -- Columns of context
-- opt.listchars+=precedes:<,extends:>
opt.scrolloff = 4 -- Lines of context

opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of curren
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width

-- Tabs & indentation
opt.expandtab = true -- Convert tab to spaces
opt.shiftwidth = 4 -- Spaces for indent width
opt.tabstop = 4 -- 1 tab == 4 spaces
opt.smartindent = true -- Autoindent new lines
opt.autoindent = true -- Copy indent from current line when starting new one

opt.shiftround = true -- Round indent

-- Search
opt.hlsearch = true -- Highlight all matches on previous search pattern
opt.incsearch = true
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true -- Ignore lowercase for the whole pattern

-- Memory and CPU
opt.hidden = true -- Enable background buffers
opt.history = 100 -- Remember N lines in history
opt.lazyredraw = false -- Faster scrolling
opt.synmaxcol = 240 -- Max column for syntax highlight
opt.updatetime = 250 -- ms to wait for trigger an event (4000ms default)
opt.timeoutlen = 300 -- ?

opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer

-- opt.pumblend = 10 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of entries in a popup
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.formatoptions = "jcroqlnt" -- tcqj

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"

-- Fix markdown indentation settings
-- vim.g.markdown_recommended_style = 0
