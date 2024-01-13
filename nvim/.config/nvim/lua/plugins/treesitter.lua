--
--
-- https://github.com/nvim-treesitter/nvim-treesitter
-- ':TSConfigInfo'
--

return {
    "nvim-treesitter/nvim-treesitter",
    -- When updates also update all included parsers
    build = ":TSUpdate",
    -- On which event plugin should be loaded
    event = {
        "BufReadPre", -- When open buffer for existing file
        "BufNewFile", -- When open a new file
    },
    config = function()
        local treesitter = require("nvim-treesitter.configs")

        treesitter.setup({
            -- A list of parser names that should be installed
            -- Supported langs: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
            ensure_installed = {
                "lua",
                "luadoc",
                "python",
                "bash",
                "json",
                "yaml",
                "markdown",
                "markdown_inline",
                -- "vim",
                -- "vimdoc",
                "gitignore",
                "dockerfile",
                "gpg",
                "dot",
                "sql",
                "ssh_config",
                "toml",
                "make", -- For `Makefile`
            },
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = false,

            -- Enable syntax highlight
            highlight = {
                enable = true, -- `false` will disable the whole plugin
                additional_vim_regex_highlighting = false,
            },
            -- Enagle indentation
            indent = {
                enable = true,
            },
        })
    end,
}
