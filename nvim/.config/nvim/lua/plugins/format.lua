-- https://github.com/stevearc/conform.nvim#installation
-- return {
--     {
--         "stevearc/conform.nvim",
--          dependencies = { "mason.nvim" },
--           lazy = true,
--           cmd = "ConformInfo",
--         config = function()
--             conform = require("conform")
--
--             conform.setup({
--                 formatters_by_ft = {
--                     lua = { "stylua" },
--                     -- Conform will run multiple formatters sequentially
--                     python = { "isort", "black" },
--                         -- Use a sub-list to run only the first available formatter
--                     javascript = { { "prettierd", "prettier" } },
--                     -- Use the "*" filetype to run formatters on all filetypes.
--                     ["*"] = { "codespell" },
--               },
--                 format_on_save = {
--                     -- These options will be passed to conform.format()
--                     timeout_ms = 500,
--                     lsp_fallback = true,
--               },
--                 -- Conform will notify you when a formatter errors
--               notify_on_error = true,
--             })
--
--             vim.api.nvim_create_autocmd("BufWritePre", {
--               pattern = "*",
--               callback = function(args)
--                 require("conform").format({ bufnr = args.buf })
--               end,
--             })
--         end,
--     }
-- }

-- return {
--   "williamboman/mason.nvim",
--   dependencies = {
--     "williamboman/mason-lspconfig.nvim",
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--   },
--   config = function()
--     -- import mason
--     local mason = require("mason")
--
--     -- import mason-lspconfig
--     local mason_lspconfig = require("mason-lspconfig")
--
--     local mason_tool_installer = require("mason-tool-installer")
--
--     -- enable mason and configure icons
--     mason.setup({
--       ui = {
--         icons = {
--           package_installed = "✓",
--           package_pending = "➜",
--           package_uninstalled = "✗",
--         },
--       },
--     })
--
--     mason_lspconfig.setup({
--       -- list of servers for mason to install
--       ensure_installed = {
--         -- "tsserver",
--         -- "html",
--         -- "cssls",
--         -- "tailwindcss",
--         -- "svelte",
--         "lua_ls",
--         -- "graphql",
--         -- "emmet_ls",
--         -- "prismals",
--         "pyright",
--       },
--       -- auto-install configured servers (with lspconfig)
--       automatic_installation = true, -- not the same as ensure_installed
--     })
--
--     mason_tool_installer.setup({
--       ensure_installed = {
--         "prettier", -- prettier formatter
--         "stylua", -- lua formatter
--         "isort", -- python formatter
--         "black", -- python formatter
--         "pylint", -- python linter
--         -- "eslint_d", -- js linter
--       },
--     })
--   end,
-- }

return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				-- javascript = { "prettier" },
				-- typescript = { "prettier" },
				-- javascriptreact = { "prettier" },
				-- typescriptreact = { "prettier" },
				-- svelte = { "prettier" },
				-- css = { "prettier" },
				-- html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				-- graphql = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
