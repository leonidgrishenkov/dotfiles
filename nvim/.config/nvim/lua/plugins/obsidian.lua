return {
    {
        "epwalsh/obsidian.nvim",
        version = "*", -- use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "main",
                    path = "~/Filen/Obsidian/main-vault",
                },
            },

            -- Optional: daily notes configuration.
            daily_notes = {
                folder = "Daily",
                date_format = "%Y-%m-%d",
            },

            -- Completion disabled: using blink.cmp instead of nvim-cmp.
            completion = {
                nvim_cmp = false,
            },

            -- Where to put new notes created via :ObsidianNew.
            notes_subdir = "Base",

            -- Use wiki-style links: [[Note Title]].
            preferred_link_style = "wiki",

            -- Follow links with gf.
            follow_url_func = function(url)
                vim.ui.open(url)
            end,

            -- Image paste configuration.
            attachments = {
                img_folder = "Attachments",
            },

            -- Templates configuration.
            templates = {
                folder = "Template",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
            },

            -- Disable frontmatter auto-generation if you manage it manually.
            disable_frontmatter = false,

            -- UI tweaks: conceal brackets, render checkboxes, etc.
            ui = {
                enable = true,
                update_debounce = 200,
                checkboxes = {
                    [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                    ["x"] = { char = "", hl_group = "ObsidianDone" },
                    [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                    ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                    ["!"] = { char = "", hl_group = "ObsidianImportant" },
                },
                bullets = { char = "•", hl_group = "ObsidianBullet" },
                external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                reference_text = { hl_group = "ObsidianRefText" },
                highlight_text = { hl_group = "ObsidianHighlightText" },
                tags = { hl_group = "ObsidianTag" },
                block_ids = { hl_group = "ObsidianBlockID" },
            },
        },
    },
}
