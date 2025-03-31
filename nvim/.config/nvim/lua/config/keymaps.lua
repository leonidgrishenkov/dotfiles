local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Remap exit modes to normal mode
vim.keymap.set({ "v", "i" }, "jf", "<ESC>", opts(nil))
