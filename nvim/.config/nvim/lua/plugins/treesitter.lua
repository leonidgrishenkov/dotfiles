--
--
-- https://github.com/nvim-treesitter/nvim-treesitter
-- ':TSConfigInfo'
--

return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			-- A list of parser names, or "all" (the five listed parsers should always be installed)
			-- Supported langs: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
			ensure_installed = { "lua", "python", "bash" },

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = false,

			-- List of parsers to ignore installing (or "all")
			ignore_install = { "" },

			-- If you need to change the installation directory of the parsers (see -> Advanced Setup)
			-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
			highlight = {
				enable = true,
			},
		})
	end,
}
