return {
    {
        --[[
        Autocompletion plugin.

        Repo: https://github.com/hrsh7th/nvim-cmp
        Wiki: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources

        Docs:
            - All docs: `nvim-cmp`
            - About configuration (in cmp.setup({})): `cmp-config`
            - All command: `cmp-command`
            - `CmpStatus`
        --]]
        -- TODO: Remove cmp invoke iside telescope
        "hrsh7th/nvim-cmp",
        version = false, -- Last release is way too old. Took from here: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/coding.lua
        event = {
            "InsertEnter", -- Load plugin when switch to insert mode
        },
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
                dependencies = {
                    "saadparwaiz1/cmp_luasnip", -- For lua autocompletion
                    "rafamadriz/friendly-snippets", -- Usefull snippets
                },
            },
            "hrsh7th/cmp-nvim-lsp",
            -- Other sources are listed here: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
            -- Buffer and path
            "hrsh7th/cmp-buffer", -- Source for text in current buffer. Repo: https://github.com/hrsh7th/cmp-buffer
            "hrsh7th/cmp-path", -- Source for file system paths. Repo: https://github.com/hrsh7th/cmp-path
            -- LSP
            "hrsh7th/cmp-cmdline", -- ?
            -- vs-code like pictograms
            -- Repo: https://github.com/onsails/lspkind.nvim
            "onsails/lspkind.nvim",
            -- Other
            "SergioRibera/cmp-dotenv", -- Cmp for env variables and dotenv file. Repo: https://github.com/SergioRibera/cmp-dotenv
        },
        config = function()
            local cmp = require("cmp")
            local defaults = require("cmp.config.default")()
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")
            -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Configure plugin
            cmp.setup({
                -- enabled = true,
                enabled = function()
                    -- Disable cmp in Telescope prompt
                    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
                    if buftype == "prompt" then
                        return false
                    end
                    return true
                end,

                completion = {
                    -- Behavior of the cmp plugin. For details see: :h completeopt
                    completeopt = "menu,menuone,preview,noinsert,noselect",
                    -- The number of characters needed to trigger auto-completion.
                    keyword_length = 2,
                },
                -- Configure how nvim-cmp interacts with snippet engine
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                -- Keymapping
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
                    ["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
                    ["<C-k>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-l>"] = cmp.mapping.scroll_docs(4),
                    ["<C-a>"] = cmp.mapping.complete(), -- Invoke cmp
                    -- Close completion window
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    -- Accept currently selected item. If none selected, `select` first item.
                    ["<CR>"] = cmp.mapping.confirm({
                        select = false, -- Set to `false` to only confirm explicitly selected items.
                        behavior = cmp.ConfirmBehavior.Replace, -- Replace current position word with suggestion
                    }),
                    -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping to accept suggestion.
                    ["<C-y>"] = cmp.config.disable,

                    -- With this enabled <Tab> doesn't work in vim command line mode ( when use `:` ) for autocompletion
                    -- ["<Tab>"] = cmp.mapping(function(fallback)
                    --     if cmp.visible() then
                    --         cmp.select_next_item()
                    --     elseif luasnip.expandable() then
                    --         luasnip.expand()
                    --     elseif luasnip.expand_or_jumpable() then
                    --         luasnip.expand_or_jump()
                    --     else
                    --         fallback()
                    --     end
                    -- end, { "i", "s" }),
                    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
                    --     if cmp.visible() then
                    --         cmp.select_prev_item()
                    --     elseif luasnip.jumpable(-1) then
                    --         luasnip.jump(-1)
                    --     else
                    --         fallback()
                    --     end
                    -- end, { "i", "s" }),
                }),
                -- Sources for autocompletion
                -- Docs: :h cmp-contig.matching
                -- WARN: Order in this list will be used to prioritize cmp results.
                sources = cmp.config.sources({
                    { name = "copilot", group_index = 1, priority = 100 },
                    { name = "nvim_lsp" },
                    { name = "luasnip", keyword_length = 3 },
                    { name = "buffer", keyword_length = 3 },
                    { name = "path", keyword_length = 6 },
                    -- { name = "cmdline" },
                    { name = "dotenv", keyword_length = 3 },
                }),
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                formatting = {
                    expandable_indicator = true,
                    fields = { "kind", "abbr", "menu" },
                    -- configure lspkind for vs-code like pictograms in completion menu
                    format = lspkind.cmp_format({
                        mode = "symbol_text", -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
                        -- Icons preset. Can be either 'default' (requires nerd-fonts font)
                        -- or 'codicons' for codicon preset (requires vscode-codicons font)
                        -- preset = "default",
                        -- Override preset symbols. Default: {} (Use from preset)
                        symbol_map = {
                            Text = "󰉿",
                            Method = "󰆧",
                            Function = "󰊕",
                            Constructor = "",
                            Field = "󰜢",
                            Variable = "󰀫",
                            Class = "󰠱",
                            Interface = "",
                            Module = "",
                            Property = "󰜢",
                            Unit = "󰑭",
                            Value = "󰎠",
                            Enum = "",
                            Keyword = "󰌋",
                            Snippet = "",
                            Color = "󰏘",
                            File = "󰈙",
                            Reference = "󰈇",
                            Folder = "󰉋",
                            EnumMember = "",
                            Constant = "󰏿",
                            Struct = "󰙅",
                            Event = "",
                            Operator = "󰆕",
                            TypeParameter = "",
                            -- https://github.com/zbirenbaum/copilot-cmp?tab=readme-ov-file#highlighting--icon
                            Copilot = "",
                        },
                        maxwidth = 60, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                        -- can also be a function to dynamically calculate max width such as
                        -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                        ellipsis_char = "..", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                        show_labelDetails = false, -- show labelDetails in menu. Disabled by default
                        --     menu = {
                        --         buffer = "[Buffer]",
                        --         nvim_lsp = "[LSP]",
                        --         -- nvim_lua = "[Lua]",
                        --         luasnip = "[LuaSnip]",
                        --         path = "[Path]",
                        --         },
                    }),
                },
                -- `:h cmp-contig.window`
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- `:h cmp-contig.matching`
                matching = defaults.matching,
                sorting = defaults.sorting,
                experimental = {
                    ghost_text = true,
                },
            })

            cmp.setup.filetype({ "sql" }, {
                sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                },
            })

            -- TODO: Is all of  these are overwrited by noice?
            -- Completions for text inside vim command lines.
            -- Setup for `/` vim cmdline.
            -- cmp.setup.cmdline({ "/", "?" }, {
            --     mapping = cmp.mapping.preset.insert({
            --         ["<C-p>"] = cmp.mapping.select_prev_item(),
            --         ["<C-n>"] = cmp.mapping.select_next_item(),
            --         ["<C-a>"] = cmp.mapping.complete(),
            --     }),
            --     sources = {
            --         { name = "buffer" },
            --     },
            -- })
            -- -- Setup for `:` vim cmdline.
            -- cmp.setup.cmdline(":", {
            --     mapping = cmp.mapping.preset.insert({
            --         ["<C-p>"] = cmp.mapping.select_prev_item(),
            --         ["<C-n>"] = cmp.mapping.select_next_item(),
            --         ["<C-a>"] = cmp.mapping.complete(),
            --     }),
            --     sources = cmp.config.sources({
            --         { { name = "path" } },
            --         {
            --             {
            --                 name = "cmdline",
            --                 option = { ignore_cmds = { "Man", "!" } },
            --             },
            --         },
            --     }),
            -- })
        end,
    },
}
