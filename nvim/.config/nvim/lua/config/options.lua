-- Enable highlighting of the current line
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number" -- highlight the line number

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

-- display all thing that are usually concealed (such as backticks in Markdown files)
vim.opt.conceallevel = 0

-- OSC52 clipboard integration for remote/container environments.
-- Set NVIM_CLIPBOARD=osc52 (e.g. in your Dockerfile, docker-compose, or .bashrc)
-- to enable clipboard bridging over SSH and inside containers via terminal escape
-- sequences. Requires Neovim 0.10+ and a terminal that supports OSC52
-- (iTerm2, WezTerm, Alacritty, Kitty, Ghostty, Windows Terminal, etc.)
if vim.fn.has("nvim-0.10") == 1 and vim.env.NVIM_CLIPBOARD == "osc52" then
    local function paste()
        return {
            vim.split(vim.fn.getreg(""), "\n"),
            vim.fn.getregtype(""),
        }
    end

    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }
end

-- Use the system clipboard for all yank/delete/change operations
vim.opt.clipboard = "unnamedplus"
