#!/bin/sh

# https://github.com/catppuccin/k9s

set -euo pipefail

echo "Updating k9s catppuccin theme"

if [ -z "$DOTFILES_DIR" ]; then
    echo 'DOTFILES_DIR env var is required'
    exit 1
fi

output="$DOTFILES_DIR/k9s/.config/k9s/skins/catppuccin"

if [ -d "$output" ]; then rm -rf "$output"; fi

mkdir -p "$output"

wget -q --show-progress \
    -O https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$output" --strip-components=2 k9s-main/dist
