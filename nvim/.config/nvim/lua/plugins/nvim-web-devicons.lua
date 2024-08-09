return {
    {
        --[[
        Icons plugin. Used by other plugins.

        Repo: https://github.com/nvim-tree/nvim-web-devicons

        Docs:
            - Run :NvimWebDeviconsHiTest to see all icons and their highlighting.
        ]]
        "nvim-tree/nvim-web-devicons",
        config = function()
            local devicons = require("nvim-web-devicons")

            devicons.setup({
                -- your personnal icons can go here (to override)
                -- you can specify color or cterm_color instead of specifying both of them
                -- DevIcon will be appended to `name`
                override = {
                    zsh = {
                        icon = "",
                        color = "#428850",
                        cterm_color = "65",
                        name = "Zsh",
                    },
                },
                -- Globally enable different highlight colors per icon (default to `true`)
                -- if set to `false` all icons will have the default icon's color
                color_icons = true,

                -- Globally enable default icons, means that other plugins can't override icons
                -- and use only defaults (default to `false`). Will get overriden by `get_icons` option
                default = false,

                -- Globally enable "strict" selection of icons - icon will be looked up in
                -- different tables, first by filename, and if not found by extension; this
                -- prevents cases when file doesn't have any extension but still gets some icon
                -- because its name happened to match some extension (default to false)
                strict = true,

                -- Same as `override` but specifically for overrides by filename
                -- takes effect when `strict` is true
                override_by_filename = {},
                -- Same as `override` but specifically for overrides by extension
                -- takes effect when `strict` is true
                override_by_extension = {
                    ["log"] = {
                        icon = "",
                        color = "#81e043",
                        name = "Log",
                    },
                    ["yaml"] = {
                        icon = "",
                        color = "#984CA1",
                        name = "Yaml",
                    },
                    ["yml"] = {
                        icon = "",
                        color = "#984CA1",
                        name = "Yaml",
                    },
                },
            })
        end,
    },
}
