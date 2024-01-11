--[[
Neovim file explorer.

Plugin:`nvim-tree`

Repo: https://github.com/nvim-tree/nvim-tree.lua

Docs:
    Seacrh: `:h nvim-tree.OPTION_NAME`
    All commands: `:h nvim-tree-commands`
    Keymapping: `h nvim-tree-mappings`. To see default section `:h nvim-tree-mappings-default`

https://www.youtube.com/watch?v=SpexCBrZ1pQ
--]]

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
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
			-- Show all keymaps
			vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
		end

		-- For center floating window configuration
		local HEIGHT_RATIO = 0.8
		local WIDTH_RATIO = 0.5

		-- Configure and enable plugin
		tree.setup({
			on_attach = on_attach_keymap,
			hijack_cursor = true,
			auto_reload_on_write = true,
			disable_netrw = false,
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
				signcolumn = "no",
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
}
