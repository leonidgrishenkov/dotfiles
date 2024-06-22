return {
    {
        --[[
        Indent guides plugin.

        Repo: https://github.com/lukas-reineke/indent-blankline.nvim

        `:h ibl.commands`
        ]]
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                -- Configures the indentation
                -- `:help ibl.config.indent`
                indent = {
                    char = "│",
                    tab_char = "│", -- Indentation for <Tab>. If not set `char` value will be used
                },
                -- `:h ibl.config.scope`
                scope = {
                    -- Scope is desibled because to highlight scopes
                    -- I use `mini.indentscope` plugin defined next.
                    enabled = false, -- Enable scope in indentation guides
                },
                exclude = {
                    -- Where plugin should be desibled
                    filetypes = {
                        "help",
                        "lazy",
                        "mason",
                        "gitcommit",
                        "lspinfo",
                        "NvimTree",
                        "checkhealth",
                        "man",
                        "TelescopePrompt",
                        "TelescopeResults",
                    },
                    -- List of buftypes for which indent-blankline is disabled
                    buftypes = {
                        "terminal",
                        "nofile",
                        "quickfix",
                        "prompt",
                    },
                },
            })
        end,
    },
}
