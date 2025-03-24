return {
    {
        --[[
        Add/delete/change word surround symbol pairs.

        Repo: https://github.com/kylechui/nvim-surround

        Docs:
            Configuration: :h nvim-surround.configuration

        Usage:
            The three "core" operations of add/delete/change can be done with the keymaps ys{motion}{char}, ds{char}, and cs{target}{replacement}, respectively.

            For the following examples, * will denote the cursor position:

                Old text                    Command         New text
            --------------------------------------------------------------------------
                surr*ound_words             ysiw)           (surround_words)
                *make strings               ys$"            "make strings"
                [delete ar*ound me!]        ds]             delete around me!
                remove <b>HTML t*ags</b>    dst             remove HTML tags
                'change quot*es'            cs'"            "change quotes"
                <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
                delete(functi*on calls)     dsf             function calls

            Detailed information on how to use this plugin can be found in :h nvim-surround.usage
        --]]
        "kylechui/nvim-surround",
        version = "^3.0.0",
        event = "VeryLazy",
        -- Keymaps to invoke surround in different modes.
        ---@type user_options
        opts = {
            keymaps = {
                insert = "<C-g>s",
                insert_line = "<C-g>S",
                normal = "ys",
                normal_cur = "yss",
                normal_line = "yS",
                normal_cur_line = "ySS",
                visual = "S",
                visual_line = "gS",
                delete = "ds",
                change = "cs",
                change_line = "cS",
            },
        },
    },
}
