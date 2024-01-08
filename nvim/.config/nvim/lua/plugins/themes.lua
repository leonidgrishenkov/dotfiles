--[[
Nord-like theme.
Repo:
    https://github.com/AlexvZyl/nordic.nvim
Docs:
    `:h nordic`
--]]

return {
	{
		-- https://github.com/catppuccin/nvim
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe", -- latte, frappe, macchiato, mocha
				transparent_background = true,
				term_colors = true,
				show_end_of_buffer = false,
				styles = {
					comments = {}, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				integrations = {
					nvimtree = true,
					cmp = true,
				},
			})
		end,
		init = function()
			vim.cmd("colorscheme catppuccin")
		end,
	},
	{
		"Shatur/neovim-ayu",
		lazy = false,
		name = "ayu",
		priority = 1000,
	},
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nordic").setup({
				on_palette = function(palette)
					return palette
				end,
				transparent_bg = true,
				noice = {
					-- Available styles: `classic`, `flat`.
					style = "classic",
				},
				telescope = {
					-- Available styles: `classic`, `flat`.
					style = "classic",
				},
				leap = {
					-- Dims the backdrop when using leap.
					dim_backdrop = false,
				},
				ts_context = {
					-- Enables dark background for treesitter-context window
					dark_background = false,
				},
			})
		end,
	},
	{
		"olivercederborg/poimandres.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("poimandres").setup({})
		end,
	},
}
