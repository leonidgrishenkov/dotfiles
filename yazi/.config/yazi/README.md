# Configurations

[Default configurations](https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset)

## Keybinds

Press `~` to open help menu with all available keybinds

## Themes

Docs: https://yazi-rs.github.io/docs/configuration/theme

Add this at the top of the `theme.toml` file:

```toml
"$schema" = "https://yazi-rs.github.io/schemas/theme.json"
```

`catppuccin` themes repo: https://github.com/catppuccin/yazi

Copy selected theme as `theme.toml`:

```sh
wget -O ~/Code/dotfiles/yazi/.config/yazi/theme.toml https://github.com/catppuccin/yazi/raw/main/themes/frappe/catppuccin-frappe-lavender.toml
```

Replace `syntect_theme ` key value with the path to the `bat` theme for `bat` preview:

```toml
syntect_theme = "~/.config/bat/themes/catppuccin-frappe.tmTheme"
```
