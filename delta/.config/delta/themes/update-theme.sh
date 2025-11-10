#!/bin/sh

set -euo pipefail

echo "Updating delta catppuccin theme"

if [ -z "$DOTFILES_DIR" ]; then
    echo 'DOTFILES_DIR env var is required'
    exit 1
fi

wget -q --show-progress \
    -O "$DOTFILES_DIR/delta/.config/delta/themes/catppuccin.gitconfig" \
    https://raw.githubusercontent.com/catppuccin/delta/refs/heads/main/catppuccin.gitconfig
