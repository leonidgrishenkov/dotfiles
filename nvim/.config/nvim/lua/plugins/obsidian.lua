-- BUG: none of pickers works for me
-- haven't found a reason
return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*", -- use latest release, remove to use latest commit
        ---@module 'obsidian'
        ---@type obsidian.config
        opts = {
            -- Disable legacy :ObsidianBacklinks etc. commands; use :Obsidian backlinks
            legacy_commands = false,

            workspaces = {
                {
                    name = "main",
                    path = "~/Filen/Obsidian/main-vault",
                },
            },

            -- Picker: snacks.picker (built-in adapter in the fork)
            picker = {
                name = "snacks.picker",
                note_mappings = {
                    insert_link = "<C-l>",
                    new = "<C-n>",
                },
                tag_mappings = {
                    tag_note = "<C-t>",
                    insert_tag = "<C-l>",
                },
            },

            -- Daily notes
            daily_notes = {
                folder = "Daily",
                date_format = "%Y-%m-%d",
            },

            -- Completion is now provided via the built-in obsidian-ls LSP server;
            -- no nvim-cmp needed.
            completion = {
                min_chars = 2,
            },

            -- Where to put new notes created via :Obsidian new
            notes_subdir = "Base",

            -- Link style (replaces deprecated preferred_link_style)
            link = {
                style = "wiki",
            },

            -- Image/attachment paste location (replaces deprecated attachments.img_folder)
            attachments = {
                folder = "Attachments",
            },

            -- Templates
            templates = {
                folder = "Template",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
            },

            -- Frontmatter (replaces deprecated disable_frontmatter)
            frontmatter = {
                enabled = true,
            },

            ui = {
                enable = true,
                ignore_conceal_warn = true,
                update_debounce = 200,
                bullets = { char = "•", hl_group = "ObsidianBullet" },
                external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
                reference_text = { hl_group = "ObsidianRefText" },
                highlight_text = { hl_group = "ObsidianHighlightText" },
                tags = { hl_group = "ObsidianTag" },
                block_ids = { hl_group = "ObsidianBlockID" },
            },

            -- Checkbox toggle order (replaces deprecated reliance on ui.checkboxes keys)
            checkbox = {
                order = { " ", "~", "!", ">", "x" },
            },

            -- URL opening uses vim.ui.open by default, no need to set follow_url_func
        },
    },
}
