[GitHub page](https://github.com/catppuccin/bat/tree/main)

Download theme file:

```sh
wget -q --show-progress \
    -O "$DOTFILES_DIR/bat/.config/bat/themes/catppuccin-latte.tmTheme" \
   "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"

wget -q --show-progress \
    -O "$DOTFILES_DIR/bat/.config/bat/themes/catppuccin-frappe.tmTheme" \
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"

wget -q --show-progress \
    -O "$DOTFILES_DIR/bat/.config/bat/themes/catppuccin-macciato.tmTheme" \
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"

wget -q --show-progress \
    -O "$DOTFILES_DIR/bat/.config/bat/themes/catppuccin-mocha.tmTheme" \
    "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
```

Make sure `DOTFILES_DIR` environment variable is set.

Rebuild bat's cache:

```sh
bat cache --build
```

```sh
bat --list-themes
```
