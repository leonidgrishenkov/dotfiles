--[[
Config for `lazy.nvim` neovim plugin manager.

Repo: https://github.com/folke/lazy.nvim
Help: :h lazy.nvim
--]]

-- Bootstrap lazy.nvim. It will automatically install and load plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Default conf: https://lazy.folke.io/configuration
require("lazy").setup({ { import = "plugins" } }, {
    defaults = {
        -- Set this to `true` to have all your plugins lazy-loaded by default.
        -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false,
    },
    install = {
        -- install missing plugins on startup. This doesn't increase startup time.
        missing = true,
        colorscheme = { "catppuccin" },
    },
    ui = {
        border = "rounded",
    },
    -- automatically check for plugin updates
    checker = {
        enabled = false,
    },
    -- automatically check for config file changes and reload the ui
    change_detection = {
        enabled = false,
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
        },
    },
})
