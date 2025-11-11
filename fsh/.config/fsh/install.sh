#!/bin/bash

set -euo pipefail

# https://github.com/catppuccin/zsh-fsh

if [ -z "$DOTFILES_DIR" ]; then
    echo 'DOTFILES_DIR env var is required'
    exit 1
fi

base_url=https://raw.githubusercontent.com/catppuccin/zsh-fsh/refs/heads/main/themes
themes=(frappe latte macchiato mocha)

for theme in "${themes[@]}"; do
    echo "Downloading theme: ${theme}"
    wget -q --show-progress \
        -O "$DOTFILES_DIR/fsh/.config/fsh/catppuccin-${theme}.ini" \
        "$base_url/catppuccin-${theme}.ini"
done
