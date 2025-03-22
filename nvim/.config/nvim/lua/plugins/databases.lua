return {
    {
        -- An overview of all settings and their default values can be found at :help vim-dadbod-ui
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
            "DBUIHideNotifications",
        },
        -- :help vim-dadbod-ui-settings
        init = function()
            vim.g.db_ui_show_database_icon = true
            vim.g.db_ui_use_nerd_fonts = true
            vim.g.db_ui_use_nvim_notify = true
            vim.g.db_ui_execute_on_save = false
        end,
    },
}
