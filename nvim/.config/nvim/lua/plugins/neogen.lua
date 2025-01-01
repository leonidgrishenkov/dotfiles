return {
    {
        --[[
        Plugin to that will create annotations for diffetent languages.
        Repo: https://github.com/danymat/neogen?tab=readme-ov-file

        Usage:
            :Neogen
            :Neogen func|class|type|...
        --]]
        "danymat/neogen",
        -- config = true,
        config = function()
            require("neogen").setup({
                enabled = true,
                -- List of supported langs:
                -- https://github.com/danymat/neogen?tab=readme-ov-file#supported-languages
                languages = {
                    python = {
                        template = {
                            annotation_convention = "google_docstrings",
                        },
                    },
                },
            })
        end,
        -- Uncomment next line if you want to follow only stable versions
        -- version = "*"
    },
}
