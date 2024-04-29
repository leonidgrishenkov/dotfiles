return {
    {
        --[[
        Repo: https://github.com/folke/which-key.nvim
        ]]
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            local whichkey = require("which-key")
            whichkey.setup({
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "➜", -- symbol used between a key and it's label
                    group = "+", -- symbol prepended to a group
                },
                window = {
                    border = "single", -- none, single, double, shadow
                    position = "bottom", -- bottom, top
                    margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
                    padding = { 1, 0, 1, 0 }, -- extra window padding [top, right, bottom, left]
                },
            })

            whichkey.register({
                f = {
                    name = "Find",
                    f = { "Find File" },
                    b = { "Find Buffer" },
                    h = { "Find Help" },
                    w = { "Find Text" },
                },
                e = { "File Manager" },
                o = { "Git status" },
                x = { "Close Buffer" },
                w = { "Save" },
                t = { name = "Terminal", f = { "Float terminal" }, h = { "Horizontal terminal" } },
                h = { "No highlight" },
                g = { name = "Git", b = "Branches", c = "Commits", s = "Status" },
                c = { name = "Comment", l = "Comment Line" },
                l = {
                    name = "LSP",
                    d = "Diagnostic",
                    D = "Hover diagnostic",
                    f = "Format",
                    r = "Rename",
                    a = "Action",
                    s = "Symbol",
                },
            }, { prefix = "<leader>" })
        end,
    },
}
