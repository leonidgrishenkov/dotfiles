-- https://github.com/nvim-tree/nvim-web-devicons/

return {
  "nvim-tree/nvim-web-devicons",
  config = function()
    local devicons = require("nvim-web-devicons")
    devicons.setup({
        color_icons = true
    })
  end,
}
