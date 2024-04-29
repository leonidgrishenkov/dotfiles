return {
    {
        --[[
        Treesitter plugin confiraguraion.

        Repo: https://github.com/nvim-treesitter/nvim-treesitter
        Wiki: https://github.com/nvim-treesitter/nvim-treesitter/wiki

        `:TSConfigInfo`

        Also:
        About treesitter objects usage: https://www.youtube.com/watch?v=CEMPq_r8UYQ
        ]]
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
            --- @diagnostic disable: missing-fields

            treesitter.setup({
                -- A list of parser names that should be installed
                -- Supported langs: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
                ensure_installed = {
                    "lua",
                    "luadoc",
                    "python",
                    "bash",
                    "json",
                    "regex",
                    "yaml",
                    "markdown",
                    "markdown_inline",
                    "gitignore",
                    "vim",
                    "vimdoc",
                    "dockerfile",
                    "gpg",
                    "sql",
                    "ssh_config",
                    "toml",
                    "make",
                    "tmux",
                },
                -- Install parsers synchronously (only applied to `ensure_installed`).
                -- false = install async
                sync_install = false,
                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,
                -- Enable syntax highlight
                highlight = {
                    enable = true, -- `false` will disable the whole plugin
                    additional_vim_regex_highlighting = false,
                    -- Disable treesitter highlight for large files when it will be too slow. Took from - https://github.com/nvim-treesitter/nvim-treesitter#modules
                    --- @diagnostic disable: unused-local
                    disable = function(lang, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                },
                -- Enable indentation guides
                indent = {
                    enable = true,
                },
            })
        end,
    },
}
