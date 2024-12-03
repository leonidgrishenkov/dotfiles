-- https://github.com/catppuccin/wezterm
function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Frappe" -- or Macchiato, Frappe, Latte
	else
		return "Catppuccin Latte"
	end
end

local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

FONT_FAMILY = "JetBrainsMonoNL Nerd Font Propo"

config.font = wezterm.font({ family = FONT_FAMILY })
config.font_size = 14

-- https://wezfurlong.org/wezterm/config/lua/config/font_rules.html
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "Medium",
			style = "Italic",
		}),
	},
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "Medium",
			style = "Normal",
		}),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "ExtraLight",
			style = "Italic",
		}),
	},
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "ExtraLight",
		}),
	},
}

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

return config
