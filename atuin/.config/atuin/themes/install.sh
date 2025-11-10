#!/bin/sh

# https://github.com/catppuccin/atuin

set -euo pipefail

echo "Installing atuin catppuccin theme"

if [ -z "$DOTFILES_DIR" ]; then
    echo 'DOTFILES_DIR env var is required'
    exit 1
fi

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-lavender.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-lavender.toml

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-mauve.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-mauve.toml

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-pink.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-pink.toml

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-rosewater.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-rosewater.toml

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-sapphire.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-sapphire.toml

wget -q --show-progress \
    -O "$DOTFILES_DIR/atuin/.config/atuin/themes/catppuccin-frappe-flamingo.toml" \
    https://raw.githubusercontent.com/catppuccin/atuin/refs/heads/main/themes/frappe/catppuccin-frappe-flamingo.toml
