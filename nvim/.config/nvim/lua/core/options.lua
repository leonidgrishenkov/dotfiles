local opt = vim.opt

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.cursorline = false -- highlight the current line
opt.numberwidth = 2 -- set number column width

-- tabs & indentation
opt.tabstop = 4 -- spaces for tabs 
opt.shiftwidth = 4 -- spaces for indent width
opt.smartindent = true -- make indenting smarter again
opt.expandtab = true -- convert tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- display lines as one long line
opt.linebreak = true -- companion to wrap, don't split words

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = false -- highlight the current cursor line

-- appearance
opt.termguicolors = true
opt.showmode = false -- don't show modes, e.g. -- INSERT --
opt.pumheight = 10 -- pop up menu height

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- files
opt.swapfile = false -- swap files
opt.backup = false -- creates a backup file
opt.undofile = true -- enable/disable persistent undo
opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.fileencoding = "utf-8" -- the encoding written to a file

-- search
opt.hlsearch = false -- highlight all matches on previous search pattern
opt.incsearch = true

opt.mouse = "a"  -- allow the mouse to be used in neovim

opt.updatetime = 300 -- faster completion (4000ms default)
