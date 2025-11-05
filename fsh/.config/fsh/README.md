This is a config for 'fast-syntax-highlighting' zsh plugin.

# Catppuccin theme

[GitHub](https://github.com/catppuccin/zsh-fsh)

Download theme file:

```sh
wget -q --show-progress \
    -O $DOTFILES_DIR/fsh/.config/fsh/catppuccin-frappe.ini \
    https://raw.githubusercontent.com/catppuccin/zsh-fsh/refs/heads/main/themes/catppuccin-frappe.ini
```

Tell plugin to use this file as theme:

```sh
fast-theme XDG:catppuccin-frappe
```
