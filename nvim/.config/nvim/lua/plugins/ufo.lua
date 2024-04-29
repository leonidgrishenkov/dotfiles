return {
    {
        --[[
        Better folding expirience.

        Repo: https://github.com/kevinhwang91/nvim-ufo

        About:
        https://www.youtube.com/watch?v=f_f08KnAJOQ
        ]]
        "kevinhwang91/nvim-ufo",
        event = "BufEnter",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        config = function()
            local ufo = require("ufo")
            --- @diagnostic disable: unused-local
            ufo.setup({
                provider_selector = function(_bufnr, _filetype, _buftype)
                    return { "lsp", "indent" }
                end,
            })

            -- Keymaps
            vim.keymap.set("n", "zR", ufo.openAllFolds)
            vim.keymap.set("n", "zM", ufo.closeAllFolds)
        end,
    },
}
