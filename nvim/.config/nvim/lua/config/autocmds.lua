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

-- Rex terminal forwards OSC52 clipboard writes from programs on any Rex host to the
-- clipboard of the machine the Rex app runs on. Mirror clipboard yanks to OSC52 so
-- yanking in nvim on a remote host reaches the local clipboard. The native provider
-- (pbcopy) stays in place, so `p` still pastes what was copied in other apps.
-- Skipped when NVIM_CLIPBOARD=osc52 already sends every copy over OSC52.
if vim.env.REX_SESSION and vim.env.NVIM_CLIPBOARD ~= "osc52" then
  local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("rex_osc52"),
    callback = function()
      -- With clipboard=unnamedplus, plain y/d/c land here as "" or "+"; skip named registers.
      local regname = vim.v.event.regname
      if regname == "" or regname == "+" or regname == "*" then
        osc52_copy(vim.v.event.regcontents)
      end
    end,
  })
end
