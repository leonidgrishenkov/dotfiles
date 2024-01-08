--[[
Plugin: `nvim-cmp`
Autocompletion plugin.

Repo: https://github.com/hrsh7th/nvim-cmp
Wiki: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources

Doc:
    - All docs: `:h nvim-cmp`
    - About configuration (in cmp.setup({})): `:h cmp-config`


To see all commands: `Cmp` + <tab>
--]]


return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        -- You can choose any another sources here: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
        -- Snippet engine. Required
        "saadparwaiz1/cmp_luasnip", 
        -- Also snippet engine?
        "L3MON4D3/LuaSnip", 
        -- Source for buffer words. Repo: https://github.com/hrsh7th/cmp-buffer
        "hrsh7th/cmp-buffer",
        -- Source for file system paths. Repo: https://github.com/hrsh7th/cmp-path
        "hrsh7th/cmp-path", 
        -- Repo: https://github.com/hrsh7th/cmp-nvim-lsp
        "hrsh7th/cmp-nvim-lsp",
        -- useful snippets
        "rafamadriz/friendly-snippets", 
        -- vs-code like pictograms
        "onsails/lspkind.nvim", 
        -- ?
        "neovim/nvim-lspconfig",
    },
    config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Configure plugin
    cmp.setup({
        enabled = true,
        completion = {
            completeopt = "menu,menuone,preview,noselect",
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
            ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
            ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
            ["<C-e>"] = cmp.mapping.abort(), -- close completion window
            -- Accept currently selected item. If none selected, `select` first item.
            -- -- Set `select` to `false` to only confirm explicitly selected items.
            ["<CR>"] = cmp.mapping.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Replace,
            }),
            -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            -- ["<C-y>"] = cmp.config.disable,

            ['<Tab>'] = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end,
            ['<S-Tab>'] = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end,
        }),
        -- Sources for autocompletion
        -- Doc: `:h cmp-contig.matching`
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" }, -- snippets
            { name = "buffer" }, -- text within current buffer
            { name = "path" }, -- file system paths
        }),
        -- configure lspkind for vs-code like pictograms in completion menu
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = lspkind.cmp_format({
                -- mode = "symbol_text",
                maxwidth = 50,
                ellipsis_char = "...",
                menu = {
                    buffer = "[Buffer]",
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[Lua]",
                    luasnip = "[LuaSnip]"
                    },
            }),
        },
        -- Doc: `:h cmp-contig.window`
        window = {
            -- documentation = {
            --     border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            -- },
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
        },
        -- Doc: `:h cmp-contig.matching`
        matching = { }
    })

    cmp.setup.cmdline({ "/" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "path" },
        },
    })
    --
    -- cmp.setup.cmdline(":", {
    --     mapping = cmp.mapping.preset.cmdline(),
    --     sources = cmp.config.sources(
    --         { { name = "path" } }
    --     ),
    -- })
    end,
}


