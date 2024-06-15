return {
    {
        --[[
        Neovim file explorer.

        Repo: https://github.com/nvim-tree/nvim-tree.lua
        Docs:
            Seacrh: `:h nvim-tree.OPTION_NAME`
            All commands: `:h nvim-tree-commands`
            Keymapping: `h nvim-tree-mappings`. To see default section `:h nvim-tree-mappings-default`
            Toggle help: `g?`

        https://www.youtube.com/watch?v=SpexCBrZ1pQ
        --]]
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-web-devicons", -- To show icons in file explorer
        },
        config = function()
            local tree = require("nvim-tree")
            local icons = require("utils.icons")

            --[[
            Global keymappings
            --]]
            local function opts(desc)
                return { desc = desc, noremap = true, silent = true, nowait = true }
            end

            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts("Show File Explorer"))
            -- vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFileToggle<CR>", opts("Toggle window on current file"))

            --[[
            On attached keymappings
            --]]
            local function on_attach_keymap(bufnr)
                -- Here define another one to add buffer
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                local api = require("nvim-tree.api")

                -- Load defaults as base
                api.config.mappings.default_on_attach(bufnr)

                -- My remappings
                -- Show all keymaps vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            end

            -- For center floating window configuration
            local HEIGHT_RATIO = 0.8
            local WIDTH_RATIO = 0.5

            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            -- Configure and enable plugin
            tree.setup({
                on_attach = on_attach_keymap,
                hijack_cursor = true,
                auto_reload_on_write = true,
                -- disable_netrw = false, -- Already disabled via options in lua/config/options.lua
                hijack_netrw = true,
                hijack_unnamed_buffer_when_opening = false,
                root_dirs = {},
                prefer_startup_root = false,
                sync_root_with_cwd = false,
                reload_on_bufenter = false,
                respect_buf_cwd = false,
                select_prompts = false,
                sort = {
                    sorter = "name",
                    folders_first = true,
                    files_first = false,
                },
                view = {
                    centralize_selection = true,
                    cursorline = true,
                    debounce_delay = 10,
                    -- side = "left",
                    preserve_window_proportions = false,
                    number = false,
                    relativenumber = false,
                    -- Show signcolumn in UI. Required for providers (if set to show in signcolumn)
                    signcolumn = "no",
                    -- Enable and configure center floating widnow.
                    -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#center-a-floating-nvim-tree-window
                    -- Also you can configure auto-resize, see above link.
                    float = {
                        enable = true,
                        quit_on_focus_loss = false,
                        open_win_config = function()
                            local screen_w = vim.opt.columns:get()
                            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
                            local window_w = screen_w * WIDTH_RATIO
                            local window_h = screen_h * HEIGHT_RATIO
                            local window_w_int = math.floor(window_w)
                            local window_h_int = math.floor(window_h)
                            local center_x = (screen_w - window_w) / 2
                            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

                            return {
                                border = "rounded",
                                relative = "editor",
                                row = center_y,
                                col = center_x,
                                width = window_w_int,
                                height = window_h_int,
                            }
                        end,
                    },
                    width = function()
                        return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
                    end,
                },
                renderer = {
                    add_trailing = false,
                    group_empty = false,
                    full_name = false,
                    -- Path at the top of the window.
                    -- `false` = don't show path.
                    root_folder_label = false, -- Default value: `:~:s?$?/..?",`
                    indent_width = 2,
                    special_files = {}, -- Default: { "Cargo.toml", "Makefile", "README.md", "readme.md" },
                    symlink_destination = true,
                    highlight_git = "name",
                    highlight_diagnostics = "none",
                    highlight_opened_files = "none",
                    highlight_modified = "none",
                    highlight_bookmarks = "none",
                    highlight_clipboard = "none",
                    indent_markers = {
                        enable = true,
                        inline_arrows = true,
                        icons = {
                            corner = "└",
                            edge = "│",
                            item = "│",
                            bottom = "─",
                            none = " ",
                        },
                    },
                    icons = {
                        web_devicons = {
                            file = {
                                enable = true,
                                color = true,
                            },
                            folder = {
                                enable = true,
                                color = true,
                            },
                        },
                        -- Posible values for placements: `after`, `before`, `signcolumn`.
                        git_placement = "after",
                        modified_placement = "before",
                        diagnostics_placement = "after",
                        padding = "  ",
                        symlink_arrow = "  ",
                        -- Which elements should be shown in UI.
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                            modified = true,
                            diagnostics = true,
                            bookmarks = false,
                        },
                        glyphs = {
                            default = "", --   
                            symlink = "",
                            bookmark = "󰆤",
                            modified = "",
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "", -- 󰉒 󱧮    
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "󱓊", --"󰽤",
                                staged = "󱓏", --"",
                                unmerged = "󱓎",
                                renamed = "󱓍",
                                untracked = "󱓋", --"◌",
                                deleted = "",
                                ignored = "󱓌",
                            },
                        },
                    },
                },
                hijack_directories = {
                    enable = true,
                    auto_open = true,
                },
                update_focused_file = {
                    enable = true,
                    update_root = true,
                    ignore_list = {},
                },
                system_open = {
                    cmd = "",
                    args = {},
                },
                git = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = false,
                    disable_for_dirs = {},
                    timeout = 400,
                    cygwin_support = false,
                },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = false,
                    debounce_delay = 50,
                    icons = {
                        error = icons.diagnostics.Error,
                        warning = icons.diagnostics.Warn,
                        hint = icons.diagnostics.Hint,
                        info = icons.diagnostics.Info,
                    },
                },
                modified = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = false,
                },
                filters = {
                    -- `true` = don't show file type.
                    git_ignored = false,
                    dotfiles = false,
                    git_clean = false,
                    no_buffer = false,
                    no_bookmark = false,
                    custom = { ".DS_Store" },
                    exclude = {},
                },
                filesystem_watchers = {
                    enable = true,
                    debounce_delay = 50,
                    ignore_dirs = {},
                },
                actions = {
                    use_system_clipboard = true,
                    change_dir = {
                        enable = true,
                        global = false,
                        restrict_above_cwd = false,
                    },
                    expand_all = {
                        max_folder_discovery = 300,
                        exclude = {},
                    },
                    open_file = {
                        quit_on_open = true,
                        eject = true,
                        resize_window = true,
                        window_picker = {
                            enable = false, -- Disable to work well with window split
                        },
                    },
                    remove_file = {
                        close_window = true,
                    },
                },
                trash = {
                    cmd = "gio trash",
                },
                tab = {
                    sync = {
                        open = false,
                        close = false,
                        ignore = {},
                    },
                },
                notify = {
                    threshold = vim.log.levels.INFO,
                    absolute_path = false,
                },
                help = {
                    sort_by = "key",
                },
                ui = {
                    confirm = {
                        remove = true,
                        trash = true,
                        default_yes = false,
                    },
                },
                experimental = {},
                log = {
                    enable = true,
                    truncate = false,
                    types = {
                        all = false,
                        config = false,
                        copy_paste = true,
                        dev = false,
                        diagnostics = true,
                        git = false,
                        profile = true,
                        watcher = true,
                    },
                },
            })
        end,
    },
}
