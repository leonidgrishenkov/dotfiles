return {
    {
        --[[
        Highlights the current level of indentation, and animates the highlighting.

        Repo: https://github.com/echasnovski/mini.indentscope
        Docs: `mini.indentscope`
        ]]
        "echasnovski/mini.indentscope",
        version = false, -- see docs on github
        event = "BufEnter",
        config = function()
            local indentscope = require("mini.indentscope")

            indentscope.setup({
                -- Draw options
                draw = {
                    -- Delay (in ms) between event and start of drawing scope indicator
                    delay = 100,
                    -- Animation rule for scope's first drawing. A function which, given
                    -- next and total step numbers, returns wait time (in ms). See
                    -- |MiniIndentscope.gen_animation| for builtin options. To disable
                    -- animation, use `require('mini.indentscope').gen_animation.none()`.
                    animation = indentscope.gen_animation.none(), -- animations are disabled now
                    -- Symbol priority. Increase to display on top of more symbols.
                    priority = 2,
                },
                -- Which character to use for drawing scope indicator
                symbol = "│",
                options = {
                    -- Whether to first check input line to be a border of adjacent scope.
                    -- Use it if you want to place cursor on function header to get scope of
                    -- its body.
                    try_as_border = true,

                    -- Whether to use cursor column when computing reference indent.
                    -- Useful to see incremental scopes with horizontal cursor movements.
                    indent_at_cursor = true,

                    -- Type of scope's border: which line(s) with smaller indent to
                    -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
                    border = "top",
                },
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    -- Textobjects
                    object_scope = "",
                    object_scope_with_border = "",

                    -- Motions (jump to respective border line; if not present - body line)
                    goto_top = "[i",
                    goto_bottom = "]i",
                },
            })

            vim.api.nvim_create_autocmd("FileType", {
                -- Where plugin should be desibled same as in exclude section of `indent-blankline` plugin.
                pattern = {
                    "help",
                    "lazy",
                    "mason",
                    "gitcommit",
                    "notify",
                    "lspinfo",
                    "NvimTree",
                    "checkhealth",
                    "man",
                    "TelescopePrompt",
                    "TelescopeResults",
                },
                --- @diagnostic disable: inject-field
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })

            -- Setup highlight color for indent sybmol.
            local catppuccin_palette = require("catppuccin.palettes").get_palette("frappe")
            -- Using catppuccin palette.
            vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = catppuccin_palette.mauve })
        end,
    },
}
