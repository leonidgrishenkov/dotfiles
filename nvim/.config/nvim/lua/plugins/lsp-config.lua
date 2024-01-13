-- Repo: https://github.com/neovim/nvim-lspconfig
-- Wiki: https://github.com/neovim/nvim-lspconfig/wiki
-- :LspInfo
return {
    "neovim/nvim-lspconfig",
    config = function()
        local lspconfig = require("lspconfig")

        -- https://github.com/microsoft/pyright
        lspconfig.pyright.setup({})

        -- lspconfig.
    end,
}
