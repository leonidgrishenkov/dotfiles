--[[
This plugins will auto close the opened parentheses

https://github.com/windwp/nvim-autopairs
--]]

return {
  "windwp/nvim-autopairs",
  event = { "InsertEnter" },
  config = function()
    -- import nvim-autopairs
    local autopairs = require("nvim-autopairs")
    -- configure autopairs
    autopairs.setup({})
  end,
}
