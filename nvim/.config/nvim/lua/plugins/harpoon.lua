--- @diagnostic disable: missing-fields
return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        --TODO: diable persistence
        init = function()
            local harpoon = require("harpoon")
            -- It's required because of autocmds. See docs.
            harpoon.setup({})

            vim.keymap.set("n", "<leader>na", function()
                harpoon:list():add()
            end, { desc = "Add item" })

            -- Default menu UI
            -- vim.keymap.set("n", "<leader>nn", function()
            --     harpoon.ui:toggle_quick_menu(harpoon:list())
            -- end, { desc = "Toggle harpoon menu" })

            -- Configure Telescope as a UI for plugin
            -- Source: github
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers")
                    .new({}, {
                        prompt_title = "Harpoon",
                        finder = require("telescope.finders").new_table({
                            results = file_paths,
                        }),
                        previewer = conf.file_previewer({}),
                        sorter = conf.generic_sorter({}),
                    })
                    :find()
            end

            vim.keymap.set("n", "<leader>nn", function()
                toggle_telescope(harpoon:list())
            end, { desc = "Open harpoon menu" })
        end,
    },
}
