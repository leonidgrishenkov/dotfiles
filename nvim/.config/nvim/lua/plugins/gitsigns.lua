return {
    {
        --[[
        Git decorations inside editor.
        Repo: https://github.com/lewis6991/gitsigns.nvim
        ]]
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local gitsigns = require("gitsigns")

            -- Setup colors for symbols in signcolomn
            vim.cmd([[
                highlight GitSignsAdd    guifg=#009900 ctermfg=2
                highlight GitSignsChange guifg=#bbbb00 ctermfg=3
            ]])

            gitsigns.setup({
                signs = {
                    add = { text = "┃", hl = "GitSignsAdd" },
                    change = { text = "┃", hl = "GitSignsChange" },
                    delete = { text = "", show_count = true },
                    topdelete = { text = "", show_count = true },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
                watch_gitdir = {
                    follow_files = true,
                },
                signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
                numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
                linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = "rounded",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },
                show_deleted = false, -- Show old version inline via virtual lines.
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end

                    -- Navigations
                    map("n", "]h", gs.next_hunk, "Next Hunk")
                    map("n", "[h", gs.prev_hunk, "Prev Hunk")

                    -- Actions
                    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
                    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                end,
            })
        end,
    },
}
