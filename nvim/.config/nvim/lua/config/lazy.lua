--[[
Config for `lazy.nvim` neovim plugin manager.
https://github.com/folke/lazy.nvim

--]]

-- Bootstrap lazy.nvim. It will automatically install and load plugin manager
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

-- Default conf: https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup({ { import = "plugins" } }, {
	defaults = {
		lazy = false,
		version = false,
	},
	install = {
		-- install missing plugins on startup. This doesn't increase startup time.
		missing = true,
		-- colorscheme = { "tokyonight", "habamax" },
	},
	-- automatically check for plugin updates
	checker = {
		enabled = false,
		concurrency = nil, ---@type number? set to 1 to check for updates very slowly
		notify = true, -- get a notification when new updates are found
		frequency = 3600, -- check for updates every hour
		check_pinned = false, -- check for pinned packages that can't be updated
	},
	-- automatically check for config file changes and reload the ui
	change_detection = {
		enabled = false,
		notify = false, -- get a notification when changes are found
	},
	performance = {
		cache = {
			enabled = true,
		},
		rtp = {
			reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
			-- disable some rtp plugins
			disabled_plugins = {
				-- "gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				-- "tarPlugin",
				-- "tohtml",
				-- "tutor",
				-- "zipPlugin",
			},
		},
	},
})
