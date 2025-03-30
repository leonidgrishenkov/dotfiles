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

            -- Setup colors for symbols in signcolomn. For staged changes I set slightly dimmed colors.
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

            local sign_priority = 100
            local signs = {
                add = { text = icons.AddSign, priority = sign_priority },
                change = { text = icons.AddSign, priority = sign_priority },
                delete = { text = icons.RemoveSign, show_count = true, priority = sign_priority },
                topdelete = { text = icons.RemoveSign, show_count = true, priority = sign_priority },
                changedelete = { text = icons.ChangeRemoveSign, priority = sign_priority },
            }

            gitsigns.setup({
                signs = signs,
                signs_staged = signs,
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
                    map("n", "]h", gs.next_hunk, "Git: next hunk")
                    map("n", "[h", gs.prev_hunk, "Git: prev hunk")

                    -- Actions
                    map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
                    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
                    map("n", "<leader>gu", gs.undo_stage_hunk, "Undo prev stage hunk")
                    map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                end,
            })
        end,
    },
}
