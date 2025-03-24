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
            opts = {
                suggestion = { enabled = false },
                panel = { enabled = false },
            },
        },
        opts = {},
    },
}
