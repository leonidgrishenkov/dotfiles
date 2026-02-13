local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "markdown" }, -- filetype names
  callback = function()
    vim.opt_local.wrap = false -- disable line wrap
    vim.opt_local.spell = false -- disable spell checker
  end,
})
