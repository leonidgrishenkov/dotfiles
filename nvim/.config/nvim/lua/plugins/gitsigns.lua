return {
    {
        --[[
        Git decorations inside editor.

        Repo: https://github.com/lewis6991/gitsigns.nvim
        Help: :help gitsigns
        ]]
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local gitsigns = require("gitsigns")
            local icons = require("utils.icons").git

            -- Setup colors for symbols in signcolomn
            -- :help  gitsigns-highlight-groups
            vim.cmd([[
                highlight GitSignsAdd    guifg=#009900 ctermfg=2
                highlight GitSignsChange guifg=#bbbb00 ctermfg=3
                highlight GitSignsDelete guifg=#E78284
                highlight GitSignsTopdelete guifg=#E78284

                highlight GitSignsStagedAdd guifg=#1a471a ctermfg=2
                highlight GitSignsStagedChange guifg=#696903 ctermfg=3
                highlight GitSignsStagedDelete guifg=#6e3435
                highlight GitSignsStagedTopdelete guifg=#6e3435
            ]])

            gitsigns.setup({
                signs = {
                    add = { text = icons.AddSign },
                    change = { text = icons.AddSign },
                    delete = { text = icons.RemoveSign, show_count = true },
                    topdelete = { text = icons.RemoveSign, show_count = true },
                    changedelete = { text = icons.ChangeRemoveSign },
                },
                signs_staged = {
                    add = { text = icons.AddSign },
                    change = { text = icons.AddSign },
                    delete = { text = icons.RemoveSign, show_count = true },
                    topdelete = { text = icons.RemoveSign, show_count = true },
                    changedelete = { text = icons.ChangeRemoveSign },
                },
                signs_staged_enable = true,
                attach_to_untracked = false,
                watch_gitdir = {
                    follow_files = true,
                },
                -- You can toggle these options with corresponding commands:
                --      :Gitsigns toggle_signs
                --      :Gitsigns toggle_numhl
                --      :Gitsigns toggle_linehl
                --      :Gitsigns toggle_word_diff
                --      :Gitsigns toggle_current_line_blame
                signcolumn = true,
                numhl = false,
                linehl = false,
                word_diff = false,
                current_line_blame = false,
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = "rounded",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end

                    -- Navigations
                    map("n", "]h", gs.next_hunk, "Next Hunk")
                    map("n", "[h", gs.prev_hunk, "Prev Hunk")

                    -- Actions
                    map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
                    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
                    -- Stage hunk in V mode
                    map("v", "<leader>gs", function()
                        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Stage hunk")
                    -- Reset hunk in V mode
                    map("v", "<leader>gr", function()
                        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Reset hunk")

                    map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
                    map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                end,
            })
        end,
    },
}
