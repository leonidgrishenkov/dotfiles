return {
    {
        --[[
        Treesitter plugin confiraguraion.

        Repo: https://github.com/nvim-treesitter/nvim-treesitter
        Wiki: https://github.com/nvim-treesitter/nvim-treesitter/wiki

        Commands:
            :TSConfigInfo
            :TSUpdate
            :TSIntall

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
        dependencies = {
            {
                -- https://github.com/nvim-treesitter/nvim-treesitter-refactor
                "nvim-treesitter/nvim-treesitter-refactor",
            },
            { "nvim-treesitter/nvim-tree-docs" },
        },
        config = function()
            --- @diagnostic disable: missing-fields
            require("nvim-treesitter.configs").setup({
                -- A list of parser names that should be installed
                -- Supported langs: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
                ensure_installed = {
                    "lua",
                    "luadoc",
                    "ninja",
                    "rst",
                    "python",
                    "bash",
                    "json",
                    "regex",
                    "yaml",
                    "markdown",
                    "markdown_inline",
                    "git_config",
                    "git_rebase",
                    "gitignore",
                    "vim",
                    "vimdoc",
                    "dockerfile",
                    "helm",
                    "gpg",
                    "sql",
                    "ssh_config",
                    "toml",
                    "make",
                    "tmux",
                    "hcl", -- terraform HCL
                    "kdl", -- KDL
                    "nginx",
                    "nix",
                    "xml",
                    "html",
                    -- "just", -- JustFile
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
                        local max_filesize = 1000 * 1024
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
                autopairs = {
                    enable = true,
                },
                rainbow = {
                    enable = true,
                    extended_mode = true,
                    max_file_lines = 300,
                },
                pairs = {
                    enable = true,
                    disable = {},
                    highlight_pair_events = { "CursorMoved" }, -- when to highlight the pairs, use {} to deactivate highlighting
                    highlight_self = true,
                },
                refactor = {
                    -- Highlights definition and usages of the current symbol under the cursor.
                    highlight_definitions = { enable = false, clear_on_cursor_move = true },
                    -- Highlights the block from the current scope where the cursor is.
                    highlight_current_scope = { enable = false },
                },
            })
        end,
    },
}
