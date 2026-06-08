local function opts(desc)
    return { desc = desc, noremap = true, silent = true }
end

-- Remap exit modes to normal mode
vim.keymap.set({ "v", "i" }, "jf", "<ESC>", opts(nil))

-- Copy file path + line number to clipboard.
local EXPAND_VARIANT = "%:~"
--[[
Useful expand variants:
1. Absolute: %:p (/Users/you/project/src/main.lua)
2. Home-relative: %:~ (~/project/src/main.lua)
3. Cwd-relative: %:~:. (src/main.lua)
4. Filename only: %:t (main.lua)
--]]
vim.keymap.set("n", "<leader>cp", function()
    local path = vim.fn.expand(EXPAND_VARIANT)
    local line = vim.fn.line(".")
    local result = path .. ":" .. line
    vim.fn.setreg("+", result)
    vim.notify("Copied file:line")
end, opts("Copy file:line"))

-- Copy file path + visual line range to clipboard
vim.keymap.set("v", "<leader>cp", function()
    local path = vim.fn.expand(EXPAND_VARIANT)
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    local result = path .. ":" .. start_line .. "-" .. end_line
    vim.fn.setreg("+", result)
    vim.notify("Copied file:line-range")
end, opts("Copy file:line-range"))

vim.keymap.set("n", "<leader>cP", function()
    local path = vim.fn.expand(EXPAND_VARIANT)
    vim.fn.setreg("+", path)
    vim.notify("Copied filepath")
end, opts("Copy filepath"))

