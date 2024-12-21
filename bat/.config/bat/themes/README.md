GitHub: https://github.com/catppuccin/bat/tree/main

Download theme file:

```sh
wget -O ~/Code/dotfiles/bat/.config/bat/themes/catppuccin-latte.tmTheme https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -O ~/Code/dotfiles/bat/.config/bat/themes/catppuccin-frappe.tmTheme https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -O ~/Code/dotfiles/bat/.config/bat/themes/catppuccin-macciato.tmTheme https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -O ~/Code/dotfiles/bat/.config/bat/themes/catppuccin-mocha.tmTheme https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
```

Rebuild bat's cache:

```sh
bat cache --build
```

```sh
bat --list-themes
```
