#!/bin/sh

echo "Updating bat catppuccin theme"

if [ -z "$DOTFILES_DIR" ]; then
    echo 'DOTFILES_DIR env var is required'
    exit 1
fi

set -euo pipefail

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

echo "Building bat cache"

bat cache --build
