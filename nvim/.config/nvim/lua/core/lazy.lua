--[[
Config for `lazy.nvim` neovim plugin manager.
https://github.com/folke/lazy.nvim

--]]

-- Bootstrap lazy.nvim.
-- It will automatically install and load
-- plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Use a protected call so we don't error out on first use
local status_ok, lazy = pcall(require, 'lazy')
if not status_ok then
  return
end

-- Load plugins.
-- Each plugin configured in it's own file
-- in `lua/plugins` or `lua/themes` directories
lazy.setup({
    {import = "plugins"}
})

