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
        version = false,
        -- When updates also update all included parsers
        build = ":TSUpdate",
        -- On which event plugin should be loaded
        event = {
            "BufReadPre",
            "BufNewFile",
        },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        keys = {
            { "<c-space>", desc = "Increment Selection" },
            { "<bs>", desc = "Decrement Selection", mode = "x" },
        },
        dependencies = {
            {
                -- https://github.com/nvim-treesitter/nvim-treesitter-refactor
                "nvim-treesitter/nvim-treesitter-refactor",
            },
            { "nvim-treesitter/nvim-tree-docs" },
        },
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup.
            -- From: https://www.lazyvim.org/plugins/treesitter#nvim-treesitter
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        opts_extend = { "ensure_installed" },
        ---@type TSConfig
        ---@diagnostic disable: missing-fields
        opts = {
            ensure_installed = {
                "lua",
                "luadoc",
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
                "hcl", -- terraform HCL
                "terraform",
                "kdl", -- KDL
                "nginx",
                "nix",
                "jinja",
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
                max_file_lines = 1000,
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
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        },
        ---@param opts TSConfig
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
