return {
    --[[
    https://github.com/zbirenbaum/copilot.lua
    --]]
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        enabled = false,
        dependencies = {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            config = function()
                require("copilot").setup({
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                })
            end,
        },
        config = function()
            require("copilot_cmp").setup({})
        end,
    },
}
