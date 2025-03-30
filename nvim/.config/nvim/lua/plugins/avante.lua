return {
    {
        -- https://github.com/yetone/avante.nvim
        "yetone/avante.nvim",
        cmd = {
            "AvanteChat",
            "AvanteToggle",
            "AvanteAsk",
        },
        enabled = true,
        version = false, -- set this if you want to always pull the latest change
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-telescope/telescope.nvim",
            "hrsh7th/nvim-cmp",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            provider = "claude",
            claude = {
                endpoint = "https://api.anthropic.com",
                model = "claude-3-7-sonnet-20250219",
                temperature = 0.5,
                max_tokens = 20000,
            },
            hints = { enabled = false },
            behaviour = {
                enable_claude_text_editor_tool_mode = true, -- Whether to enable Claude Text Editor Tool Mode.
            },
            windows = {
                width = 45, -- default % based on available width
            },
        },
    },
}
