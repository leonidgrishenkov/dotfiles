-- Enable highlighting of the current line
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number" -- highlight the line number

-- Number of spaces tabs count for
vim.opt.tabstop = 4
-- Size of an indent
vim.opt.shiftwidth = 4

-- LazyVim auto format
vim.g.autoformat = false

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

-- Set to `true` to follow the main branch
-- you need to have a working rust toolchain to build the plugin
-- in this case.
vim.g.lazyvim_blink_main = false

-- Snacks animations
-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = false
