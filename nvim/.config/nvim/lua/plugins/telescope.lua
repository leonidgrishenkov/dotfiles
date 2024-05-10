return {
    {
        --[[
        Telescope plugin.

        Repo: https://github.com/nvim-telescope/telescope.nvim
        Wiki: https://github.com/nvim-telescope/telescope.nvim/wiki
        Telescope extensions: https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions

        Usefull commands:
            `checkhealth telescope`

        Docs:
            `telescope`
        ]]
        "nvim-telescope/telescope.nvim",
        version = false, -- telescope did only one release, so use HEAD for now
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                -- Instalation using `make`.
                -- See: https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#make-linux-macos-windows-with-mingw
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope-ui-select.nvim",
        },

        config = function()
            local telescope = require("telescope")
            -- All available actions - `:h telescope.actions`
            local actions = require("telescope.actions")
            local builtin = require("telescope.builtin")
            local themes = require("telescope.themes")

            -- Global keymappings
            -- All available pickers listed here: https://github.com/nvim-telescope/telescope.nvim#pickers
            vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
            vim.keymap.set("n", "<leader>fp", ":Telescope<CR>", { desc = "Panel" })
            vim.keymap.set("n", "<leader>fc", ":Telescope commands<CR>", { desc = "Commands" })
            vim.keymap.set("n", "<leader>fo", ":Telescope vim_options<CR>", { desc = "Options" })
            -- Files
            vim.keymap.set("n", "<leader>fs", ":Telescope live_grep<CR>", { desc = "Files by string" })
            vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Files by file name" })
            -- Buffers
            vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers by file name" })
            vim.keymap.set(
                "n",
                "<leader>fz",
                ":Telescope current_buffer_fuzzy_find<CR>",
                { desc = "Fuzzy in current buffer" }
            )

            telescope.setup({
                defaults = {
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    -- With this mode telescope will start
                    initial_mode = "insert",
                    -- Determines what happens if you try to scroll past the view of the picker.
                    scroll_strategy = "cycle",
                    -- `:h telescope.layout`
                    layout_strategy = "vertical",
                    path_display = {
                        "truncate",
                    },
                    color_devicons = true,
                    -- On attached to client keymapping (inside opened plugin window)

                    mappings = {
                        -- For normal mode
                        n = {
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,

                            ["<C-w>"] = actions.move_selection_worse,
                            ["<C-b>"] = actions.move_selection_better,

                            ["<C-k>"] = actions.preview_scrolling_up,
                            ["<C-l>"] = actions.preview_scrolling_down,

                            ["<esc>"] = actions.close,

                            -- This is which key for telescope itself
                            ["?"] = actions.which_key,
                        },
                        -- For insert mode
                        i = {
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,

                            ["<C-w>"] = actions.move_selection_worse,
                            ["<C-b>"] = actions.move_selection_better,

                            ["<C-k>"] = actions.preview_scrolling_up,
                            ["<C-l>"] = actions.preview_scrolling_down,

                            ["<esc>"] = actions.close,
                        },
                    },
                    --  A table of lua regex that define the files that should be ignored.
                    file_ignore_pattern = {
                        "node_modules",
                        "yarn.lock",
                        ".git",
                        ".sl",
                        "_build",
                        ".next",
                    },
                    -- preview configurations
                    preview = {
                        -- Don't show preview for files larger than specified value.
                        filesize_limit = 0.5, -- MB
                        -- treesitter highlighting for all available filetypes
                        treesitter = true,
                        -- show preview when telescope was opened
                        hide_on_startup = false,
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        themes.get_dropdown({}),
                    },
                },
            })

            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")
            telescope.load_extension("noice")
            telescope.load_extension("notify")
        end,
    },
}
