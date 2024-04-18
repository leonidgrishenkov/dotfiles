return {
    {
        --[[
    Icons plugin. Used by other plugins.
    
    Repo: https://github.com/nvim-tree/nvim-web-devicons
    ]]
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        config = function()
            local devicons = require("nvim-web-devicons")

            devicons.setup({
                -- your personnal icons can go here (to override)
                -- you can specify color or cterm_color instead of specifying both of them
                -- DevIcon will be appended to `name`
                override = {
                    zsh = {
                        icon = "",
                        color = "#428850",
                        cterm_color = "65",
                        name = "Zsh",
                    },
                },
                -- Globally enable different highlight colors per icon (default to `true`)
                -- if set to `false` all icons will have the default icon's color
                color_icons = true,

                -- Globally enable default icons, means that other plugins can't override icons
                -- and use only defaults (default to `false`). Will get overriden by `get_icons` option
                default = false,

                -- Globally enable "strict" selection of icons - icon will be looked up in
                -- different tables, first by filename, and if not found by extension; this
                -- prevents cases when file doesn't have any extension but still gets some icon
                -- because its name happened to match some extension (default to false)
                strict = true,

                -- Same as `override` but specifically for overrides by filename
                -- takes effect when `strict` is true
                override_by_filename = {
                    [".gitignore"] = {
                        icon = "󰊢",
                        color = "#984CA1",
                        name = "Gitignore",
                    },
                    [".gitconfig"] = {
                        icon = "󰊢",
                        color = "#984CA1",
                        name = "Gitconfig",
                    },
                },
                -- Same as `override` but specifically for overrides by extension
                -- takes effect when `strict` is true
                override_by_extension = {
                    ["log"] = {
                        icon = "",
                        color = "#81e043",
                        name = "Log",
                    },
                    ["yaml"] = {
                        icon = "",
                        color = "",
                        name = "Yaml",
                    },
                },
            })
        end,
    },
    {
        --[[
        UI components plugin.
        Repo: https://github.com/MunifTanjim/nui.nvim
        ]]
        "MunifTanjim/nui.nvim",
        lazy = true,
    },
    {
        --[[
        This plugin replace standart UI for messages, cmdline and popupmenu.
        
        Repo: https://github.com/folke/noice.nvim
        Wiki: https://github.com/folke/noice.nvim/wiki
        
        `:checkhealth noice`
        ]]
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "nui.nvim",
        },
        config = function()
            local noice = require("noice")

            -- `:h noice.nvim-noice-configuration`
            noice.setup({
                cmdline = {
                    -- enables the Noice cmdline UI
                    enabled = true,
                    -- All available types of view: `:h noice.nvim-noice-views`
                    view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
                    format = {
                        cmdline = { pattern = "^:", icon = "", lang = "vim" },
                        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                        lua = {
                            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
                            icon = "",
                            lang = "lua",
                        },
                        help = { pattern = "^:%s*he?l?p?%s+", icon = " " },
                    },
                },
                popupmenu = {
                    enabled = true, -- enables the Noice popupmenu UI
                    backend = "cmp", -- backend to use to show regular cmdline completions: `nui` or `cmp`
                    kind_icons = {}, -- set to `false` to disable icons
                },
                messages = {
                    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                    -- This is a current Neovim limitation.
                    enabled = false, -- enables the Noice messages UI
                    view = "notify", -- default view for messages
                    view_error = "notify", -- view for errors
                    view_warn = "notify", -- view for warnings
                    view_history = "messages", -- view for :messages
                    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
                },
                -- Views configurations.
                -- See all options here - https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
                view = {
                    popupmenu = {
                        relative = "editor",
                        -- zindex = 65, -- ?
                        -- when auto, then it will be positioned to the cmdline or cursor
                        position = {
                            row = 8,
                            col = "50%",
                        },
                        size = {
                            width = 60,
                            height = 10,
                            -- max_height = 20,
                            -- min_width = 10,
                        },
                        win_options = {
                            winbar = "",
                            foldenable = false,
                            cursorline = true,
                            cursorlineopt = "line",
                            winhighlight = {
                                -- Normal = "NoicePopupmenu", -- change to NormalFloat to make it look like other floats
                                Normal = "Normal",
                                FloatBorder = "DiagnosticInfo",
                                -- FloatBorder = "NoicePopupmenuBorder", -- border highlight
                                CursorLine = "NoicePopupmenuSelected", -- used for highlighting the selected item
                                PmenuMatch = "NoicePopupmenuMatch", -- used to highlight the part of the item that matches the input
                            },
                        },
                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                    },
                    --     popup = {
                    --         backend = "popup",
                    --         relative = "editor",
                    --         close = {
                    --             events = { "BufLeave" },
                    --             keys = { "q" },
                    --         },
                    --         enter = true,
                    --         border = {
                    --             style = "rounded",
                    --             padding = { 0, 1 },
                    --         },
                    --         position = "50%",
                    --         size = {
                    --             width = "120",
                    --             height = "20",
                    --         },
                    --         win_options = {
                    --             winhighlight = { Normal = "NoicePopup", FloatBorder = "NoicePopupBorder" },
                    --             winbar = "",
                    --             foldenable = false,
                    --         },
                    --     },
                    --     virtualtext = {
                    --         backend = "virtualtext",
                    --         format = { "{message}" },
                    --         hl_group = "NoiceVirtualText",
                    --     },
                    cmdline_popup = {
                        -- backend = "popup",
                        -- relative = "editor",
                        -- focusable = false,
                        -- enter = false,
                        -- zindex = 200,
                        position = {
                            row = 5,
                            col = "50%",
                        },
                        size = {
                            -- min_width = 60,
                            width = 60,
                            height = "auto",
                        },
                        -- border = {
                        --     style = "rounded",
                        --     padding = { 0, 1 },
                        -- },
                        --     win_options = {
                        --         winhighlight = {
                        --             Normal = "NoiceCmdlinePopup",
                        --             FloatTitle = "NoiceCmdlinePopupTitle",
                        --             FloatBorder = "NoiceCmdlinePopupBorder",
                        --             IncSearch = "",
                        --             CurSearch = "",
                        --             Search = "",
                        --         },
                        --         winbar = "",
                        --         foldenable = false,
                        --         cursorline = false,
                        --     },
                    },
                    cmdline_output = {
                        format = "details",
                        view = "popup",
                    },
                    --     confirm = {
                    --         backend = "popup",
                    --         relative = "editor",
                    --         focusable = false,
                    --         align = "center",
                    --         enter = false,
                    --         zindex = 210,
                    --         format = { "{confirm}" },
                    --         position = {
                    --             row = "50%",
                    --             col = "50%",
                    --         },
                    --         size = "auto",
                    --         border = {
                    --             style = "rounded",
                    --             padding = { 0, 1 },
                    --             text = {
                    --                 top = " Confirm ",
                    --             },
                    --         },
                    --         win_options = {
                    --             winhighlight = {
                    --                 Normal = "NoiceConfirm",
                    --                 FloatBorder = "NoiceConfirmBorder",
                    --             },
                    --             winbar = "",
                    --             foldenable = false,
                    --         },
                    --     },
                    --     split = {
                    --         backend = "split",
                    --         enter = false,
                    --         relative = "editor",
                    --         position = "bottom",
                    --         size = "20%",
                    --         close = {
                    --             keys = { "q" },
                    --         },
                    --         win_options = {
                    --             winhighlight = { Normal = "NoiceSplit", FloatBorder = "NoiceSplitBorder" },
                    --             wrap = true,
                    --         },
                    --     },
                    --     vsplit = {
                    --         view = "split",
                    --         position = "right",
                    --     },
                },
            })
        end,
    },
    {
        --[[
        Neovim file explorer.

        Repo: https://github.com/nvim-tree/nvim-tree.lua
        Docs:
            Seacrh: `:h nvim-tree.OPTION_NAME`
            All commands: `:h nvim-tree-commands`
            Keymapping: `h nvim-tree-mappings`. To see default section `:h nvim-tree-mappings-default`

        https://www.youtube.com/watch?v=SpexCBrZ1pQ
        --]]
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-web-devicons", -- To show icons in file explorer
        },
        config = function()
            local tree = require("nvim-tree")

            --[[
            Global keymappings
            --]]
            local function opts(desc)
                return { desc = "nvim-tree: " .. desc, noremap = true, silent = true, nowait = true }
            end

            -- Toggle window
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<cr>", opts("Toggle window"))
            -- Toggle window on current file
            vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFileToggle<cr>", opts("Toggle window on current file"))

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
                    signcolumn = "yes", -- ?
                    -- Enable and configure center floating widnow.
                    -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#center-a-floating-nvim-tree-window
                    -- Also you can configure auto-resize, see above link.
                    float = {
                        enable = true,
                        quit_on_focus_loss = true,
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
                    -- Path at the top of the window
                    root_folder_label = ":~:s?$?/..?",
                    indent_width = 2,
                    special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
                    symlink_destination = true,
                    highlight_git = false,
                    highlight_diagnostics = false,
                    highlight_opened_files = "name",
                    highlight_modified = "none",
                    highlight_bookmarks = "none",
                    highlight_clipboard = "name",
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
                        git_placement = "before",
                        modified_placement = "after",
                        diagnostics_placement = "signcolumn",
                        bookmarks_placement = "signcolumn",
                        padding = "   ",
                        symlink_arrow = " ➛ ",
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = false,
                            modified = false,
                            diagnostics = true,
                            bookmarks = false,
                        },
                        glyphs = {
                            default = "",
                            symlink = "",
                            bookmark = "󰆤",
                            modified = "●",
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "✗",
                                staged = "✓",
                                unmerged = "",
                                renamed = "➜",
                                untracked = "★",
                                deleted = "",
                                ignored = "◌",
                            },
                        },
                    },
                },
                hijack_directories = {
                    enable = true,
                    auto_open = true,
                },
                update_focused_file = {
                    enable = false,
                    update_root = false,
                    ignore_list = {},
                },
                system_open = {
                    cmd = "",
                    args = {},
                },
                git = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                    disable_for_dirs = {},
                    timeout = 400,
                    cygwin_support = false,
                },
                diagnostics = {
                    enable = false,
                    show_on_dirs = false,
                    show_on_open_dirs = true,
                    debounce_delay = 50,
                    severity = {
                        min = vim.diagnostic.severity.HINT,
                        max = vim.diagnostic.severity.ERROR,
                    },
                    icons = {
                        hint = "",
                        info = "",
                        warning = "",
                        error = "",
                    },
                },
                modified = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                },
                filters = {
                    git_ignored = false,
                    dotfiles = false,
                    git_clean = false,
                    no_buffer = false,
                    no_bookmark = false,
                    custom = { ".DS_Store" },
                    exclude = {},
                },
                live_filter = {
                    prefix = "[FILTER]: ",
                    always_show_folders = true,
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
                    file_popup = {
                        open_win_config = {
                            col = 1,
                            row = 1,
                            relative = "cursor",
                            border = "shadow",
                            style = "minimal",
                        },
                    },
                    open_file = {
                        quit_on_open = false,
                        eject = true,
                        resize_window = true,
                        window_picker = {
                            enable = true,
                            picker = "default",
                            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                            exclude = {
                                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                                buftype = { "nofile", "terminal", "help" },
                            },
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
                    absolute_path = true,
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
                    enable = false,
                    truncate = false,
                    types = {
                        all = false,
                        config = false,
                        copy_paste = false,
                        dev = false,
                        diagnostics = false,
                        git = false,
                        profile = false,
                        watcher = false,
                    },
                },
            })
        end,
    },
    {
        --[[
        Telescope plugin.
        Repo: https://github.com/nvim-telescope/telescope.nvim
        Wiki: https://github.com/nvim-telescope/telescope.nvim/wiki

        `:checkhealth telescope`
        `:h telescope`

        Commands can be called only through apis.
        ]]
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                enabled = vim.fn.executable("make") == 1, -- Took from - https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
                build = "make",
            },
            "nvim-web-devicons",
        },
        config = function()
            local telescope = require("telescope")
            -- All available actions - `:h telescope.actions`
            local actions = require("telescope.actions")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    -- With this mode telescope will start
                    initial_mode = "insert",
                    -- Determines what happens if you try to scroll past the view of the picker.
                    scroll_strategy = "limit",
                    -- `:h telescope.layout`
                    layout_strategy = "horizontal",
                    path_display = {
                        "truncate",
                    },
                    -- On attached keymapping
                    mappings = {
                        -- For normal mode
                        n = {
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,

                            ["<C-w>"] = actions.move_selection_worse,
                            ["<C-b>"] = actions.move_selection_better,

                            ["<C-k>"] = actions.preview_scrolling_up,
                            ["<C-l>"] = actions.preview_scrolling_down,

                            ["<C-c>"] = actions.close,

                            ["<C-/>"] = actions.which_key,
                        },
                        -- For insert mode
                        i = {
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,

                            ["<C-w>"] = actions.move_selection_worse,
                            ["<C-b>"] = actions.move_selection_better,

                            ["<C-k>"] = actions.preview_scrolling_up,
                            ["<C-l>"] = actions.preview_scrolling_down,

                            ["<C-c>"] = actions.close,

                            ["<C-/>"] = actions.which_key,
                        },
                    },
                    -- preview configurations
                    preview = {
                        -- treesitter highlighting for all available filetypes
                        treesitter = true,
                        -- show preview when telescope was opened
                        hide_on_startup = false,
                    },
                },
            })

            telescope.load_extension("fzf")

            -- Global keymappings
            local function opts(desc)
                return { desc = desc, noremap = true, silent = true }
            end
            -- All available pickers listed here - https://github.com/nvim-telescope/telescope.nvim#pickers
            vim.keymap.set("n", "<leader>ff", builtin.find_files, opts("Search for file name in pwd"))
            vim.keymap.set("n", "<leader>ft", builtin.live_grep, opts("Search for word in files in pwd"))
            vim.keymap.set("n", "<leader>fb", builtin.buffers, opts("Search for file name in opened buffers"))
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, opts("Search for file name in recent files"))
            vim.keymap.set("n", "<leader>*", builtin.grep_string, opts("Search for pattern in pwd files"))
            vim.keymap.set("n", "<leader>gb", builtin.git_branches, opts("Search for git branch in pwd"))
            vim.keymap.set("n", "<leader>gc", builtin.git_branches, opts("Search for git commit in pwd"))
            vim.keymap.set("n", "<leader>gs", builtin.git_status, opts("Search for git status in pwd"))

            vim.keymap.set("n", "gr", builtin.lsp_references, opts(""))
            -- vim.keymap.set("n", "gd", builtin.lsp_definitions, opts(""))
        end,
    },
    {
        --[[
        That plugin improves UI and enables telescope plugin
        for two neovim builtin functions: `vim.ui.select()` and `vim.ui.input()`.
        When one of that functions called from any plugin improved version will be shown.
        Repo: https://github.com/stevearc/dressing.nvim
        ]]
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        -- `:h dressing-configuration`
        config = function()
            local dressing = require("dressing")

            dressing.setup({
                -- input = {
                --     -- Set to false to disable the vim.ui.input implementation
                --     enabled = true,
                --     -- Default prompt string
                --     default_prompt = "Input",
                --     -- Trim trailing `:` from prompt
                --     trim_prompt = true,
                --     -- Can be 'left', 'right', or 'center'
                --     title_pos = "center",
                --     -- When true, <Esc> will close the modal
                --     insert_only = true,
                --     -- When true, input will start in insert mode.
                --     start_in_insert = true,
                --     -- These are passed to nvim_open_win
                --     border = "rounded",
                --     -- 'editor' and 'win' will default to being centered
                --     relative = "cursor",
                --     -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                --     prefer_width = 40,
                --     width = nil,
                --     -- min_width and max_width can be a list of mixed types.
                --     -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
                --     max_width = { 140, 0.9 },
                --     min_width = { 20, 0.2 },
                --     buf_options = {},
                --     win_options = {
                --         -- Disable line wrapping
                --         wrap = false,
                --         -- Indicator for when text exceeds window
                --         list = true,
                --         listchars = "precedes:...,extends:...",
                --         -- Increase this for more context when text scrolls off the window
                --         sidescrolloff = 0,
                --     },
                --     -- Set to `false` to disable
                --     mappings = {
                --         -- For normal mode
                --         n = false,
                --         -- For insert mode
                --         i = {
                --             ["<Esc>"] = "Close",
                --             ["<C-c>"] = "Close",
                --             ["<CR>"] = "Confirm",
                --             ["<C-p>"] = "HistoryPrev",
                --             ["<C-n>"] = "HistoryNext",
                --         },
                --     },
                -- },
                -- select = {
                --     -- Set to false to disable the vim.ui.select implementation
                --     enabled = true,
                --     -- Priority list of preferred vim.select implementations
                --     backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
                --     -- Options for built-in selector
                --     builtin = {
                --         -- Display numbers for options and set up keymaps
                --         show_numbers = true,
                --         -- These are passed to nvim_open_win
                --         border = "rounded",
                --         -- 'editor' and 'win' will default to being centered
                --         relative = "editor",
                --         buf_options = {},
                --         win_options = {
                --             cursorline = true,
                --             cursorlineopt = "number",
                --         },
                --         -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                --         -- the min_ and max_ options can be a list of mixed types.
                --         -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
                --         width = nil,
                --         max_width = { 140, 0.8 },
                --         min_width = { 40, 0.2 },
                --         height = nil,
                --         max_height = 0.9,
                --         min_height = { 10, 0.2 },
                --         -- Set to `false` to disable
                --         mappings = {
                --             ["<Esc>"] = "Close",
                --             ["<C-c>"] = "Close",
                --             ["<CR>"] = "Confirm",
                --             ["<C-p>"] = "HistoryPrev",
                --             ["<C-n>"] = "HistoryNext",
                --         },
                --     },
                -- },
            })
        end,
    },
    {
        --[[
        Git decorations inside editor.
        Repo: https://github.com/lewis6991/gitsigns.nvim
        ]]
        "lewis6991/gitsigns.nvim",
        config = function()
            local gitsigns = require("gitsigns")

            vim.cmd([[
                highlight GitSignsAdd    guifg=#009900 ctermfg=2
                highlight GitSignsChange guifg=#bbbb00 ctermfg=3
            ]])

            gitsigns.setup({
                signs = {
                    add = { text = "┃", hl = "GitSignsAdd" },
                    change = { text = "┃", hl = "GitSignsChange" },
                    delete = { text = "▁", show_count = true },
                    topdelete = { text = "▔", show_count = true },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
            })
        end,
    },
    {
        --[[
        Repo: https://github.com/folke/which-key.nvim
        ]]
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            local whichkey = require("which-key")
            whichkey.setup({})

            whichkey.register({
                f = {
                    name = "Find",
                    f = { "Find File" },
                    b = { "Find Buffer" },
                    h = { "Find Help" },
                    w = { "Find Text" },
                },
                e = { "File Manager" },
                o = { "Git status" },
                x = { "Close Buffer" },
                w = { "Save" },
                t = { name = "Terminal", f = { "Float terminal" }, h = { "Horizontal terminal" } },
                h = { "No highlight" },
                g = { name = "Git", b = "Branches", c = "Commits", s = "Status" },
                c = { name = "Comment", l = "Comment Line" },
                l = {
                    name = "LSP",
                    d = "Diagnostic",
                    D = "Hover diagnostic",
                    f = "Format",
                    r = "Rename",
                    a = "Action",
                    s = "Symbol",
                },
            }, { prefix = "<leader>" })
        end,
    },
    {
        --[[
        Highlights comments contains word such TODO, FIX etc.
        Repo: https://github.com/folke/todo-comments.nvim
        --]]
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "TodoTrouble", "TodoTelescope" },
        opts = {},
    },
    {
        --[[
        Repo: https://github.com/folke/trouble.nvim
        --]]
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
        opts = {},
    },
}
