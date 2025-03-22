local function augroup(name)
    return vim.api.nvim_create_augroup("LocalAutoCmd" .. name, { clear = true })
end

-- Strip trailing spaces before write
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--     group = augroup("strip_space"),
--     pattern = { "*" },
--     callback = function()
--         vim.cmd([[ %s/\s\+$//e ]])
--     end,
-- })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})
