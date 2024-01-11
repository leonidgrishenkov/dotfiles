-- Repo: https://github.com/neovim/nvim-lspconfig
-- Wiki: https://github.com/neovim/nvim-lspconfig/wiki
return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")

		lspconfig.pyright.setup({})
	end,
}
