-- require("core.keymaps")
-- require("core.options")
-- require("plugins")

if vim.g.vscode then -- If neovim used from vscode
    require("core.keymaps")
    require("core.options")
else 
    require("core.keymaps")
    require("core.options")
    require("core.lazy")
end



