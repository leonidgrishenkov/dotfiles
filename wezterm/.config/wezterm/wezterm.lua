-- https://wezfurlong.org/wezterm/config/files.html
-- https://wezfurlong.org/wezterm/config/lua/general.html
--
-- Dinamically set theme depends on system appearance.
-- https://github.com/catppuccin/wezterm
-- local function scheme_for_appearance(appearance)
-- 	if appearance:find("Dark") then
-- 		return "Catppuccin Frappe"
-- 	else
-- 		return "Catppuccin Latte"
-- 	end
-- end

local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.color_scheme = "Catppuccin Macchiato" -- Available options: Macchiato, Frappe, Latte, Mocha

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

config.window_background_opacity = 0.94
config.macos_window_background_blur = 100

-- Whether to display a confirmation prompt when the window is closed by the windowing environment.
config.window_close_confirmation = "NeverPrompt"

-- Disable bell sound.
config.audible_bell = "Disabled"

config.keys = {
	{
		-- Disable 'CMD + t' keybind.
		key = "t",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
