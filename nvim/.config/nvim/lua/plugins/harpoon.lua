return {
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            -- Ensure picker sources table exists
            opts.picker = opts.picker or {}
            opts.picker.sources = opts.picker.sources or {}

            -- Add harpoon picker source
            opts.picker.sources.harpoon = {
                finder = function()
                    local harpoon = require("harpoon")
                    local list = harpoon:list()
                    local items = {}

                    for idx = 1, list:length() do
                        local item = list:get(idx)
                        if item and item.value then
                            local file = item.value
                            local exists = vim.loop.fs_stat(file) ~= nil

                            table.insert(items, {
                                idx = idx,
                                text = file,
                                file = file,
                                harpoon_idx = idx,
                                exists = exists,
                                pos = item.context and item.context.row and { item.context.row, item.context.col or 0 }
                                    or nil,
                            })
                        end
                    end

                    return items
                end,

                -- Use file formatter with custom icon
                format = "file",

                title = "  Harpoon",
                prompt = " ",

                -- Sort by harpoon index
                sort = {
                    fields = { "harpoon_idx" },
                },

                -- Don't fuzzy match - keep in order
                matcher = {
                    fuzzy = false,
                    sort_empty = false,
                },

                -- Custom actions
                actions = {
                    remove_harpoon = function(picker)
                        local item = picker:current()
                        if item and item.harpoon_idx then
                            require("harpoon"):list():remove_at(item.harpoon_idx)
                            picker:refresh()
                        end
                    end,
                    clear_harpoon = function(picker)
                        require("harpoon"):list():clear()
                        picker:refresh()
                    end,
                },

                win = {
                    input = {
                        keys = {
                            ["<C-x>"] = { "remove_harpoon", mode = { "n", "i" }, desc = "Remove from Harpoon" },
                            ["<C-r>"] = { "clear_harpoon", mode = { "n", "i" }, desc = "Remove all from Harpoon" },
                        },
                    },
                    list = {
                        keys = {
                            ["dd"] = { "remove_harpoon", desc = "Remove from Harpoon" },
                        },
                    },
                },
            }

            return opts
        end,

        keys = {
            {
                "<leader>fh",
                function()
                    Snacks.picker.pick("harpoon")
                end,
                desc = "Find Harpoon Marks",
            },
        },
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        opts = {
            settings = {
                save_on_toggle = true,
            },
        },
    },
}
