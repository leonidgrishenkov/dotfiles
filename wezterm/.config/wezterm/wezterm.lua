-- Dinamically set theme depends on system appearance.
-- https://github.com/catppuccin/wezterm
local function scheme_for_appearance(appearance)
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
			weight = "Bold",
			style = "Italic",
		}),
	},
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "Bold",
			style = "Normal",
		}),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "Medium",
			style = "Italic",
		}),
	},
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font({
			family = FONT_FAMILY,
			weight = "Medium",
		}),
	},
}

-- Disable entire tab bar.
config.enable_tab_bar = false
-- Tab bar can only be used to resize window.
-- If you set it to `NONE` tab bar will have no any functionality.
config.window_decorations = "RESIZE"

config.window_background_opacity = 0.92
config.macos_window_background_blur = 40

-- Disable bell sound.
config.audible_bell = "Disabled"

return config
