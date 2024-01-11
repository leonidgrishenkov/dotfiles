--[[
Comment/uncomment editor lines with keymaps.
Repo: https://github.com/numToStr/Comment.nvim

Docs: `h: comment-nvim`
]]

return {
	"numToStr/Comment.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		local comment = require("Comment")
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

		-- Configure and enable
		comment.setup({
			-- for commenting tsx and jsx files
			pre_hook = ts_context_commentstring.create_pre_hook(),
			---Lines to be ignored while (un)comment
			ignore = "^$", -- Ignore empty lines in all filetypes
			---LHS of toggle mappings in NORMAL mode
			toggler = {
				--Line-comment toggle keymap
				line = "<leader>/",
			},
			-- LHS of operator-pending mappings in NORMAL and VISUAL mode
			opleader = {
				-- Line-comment keymap
				line = "<leader>/",
				-- Block-comment keymap
				block = "<leader>//",
			},
		})
	end,
}
