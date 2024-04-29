return {
    {
        --[[
        Repo: https://github.com/folke/trouble.nvim
        --]]
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
        opts = {
            -- WARN: Sings defined in lsp config
            use_diagnostic_signs = true,
        },
        keys = {
            { "<leader>xx", "<cmd>TroubleToggle<CR>", desc = "Open/close trouble list" },
            {
                "<leader>xw",
                "<cmd>TroubleToggle workspace_diagnostics<CR>",
                desc = "Open trouble workspace diagnostics",
            },
            { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", desc = "Open trouble document diagnostics" },
            { "<leader>xl", "<cmd>TroubleToggle loclist<CR>", desc = "Open trouble location list" },
            { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Open todos in trouble" },
        },
    },
}
