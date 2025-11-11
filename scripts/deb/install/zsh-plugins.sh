#!/bin/bash

set -euo pipefail

function install_plugin() {
    repo_url="$1"

    plugin_name=$(basename "$repo_url" .git)
    echo "Installing zsh plugin: $plugin_name"

    plugin_dir="$XDG_DATA_HOME/$plugin_name"

    if [ -z "$XDG_DATA_HOME" ]; then
        echo 'XDG_DATA_HOME env var is required'
        exit 1
    fi

    if [ -d "$plugin_dir" ]; then
        echo "$plugin_name had already been installed into $plugin_dir, pulling updates"
        git -C "$plugin_dir" pull
    else
        git clone "$repo_url" "$plugin_dir"
    fi
}

install_plugin https://github.com/jeffreytse/zsh-vi-mode.git
install_plugin https://github.com/zdharma-continuum/fast-syntax-highlighting.git
install_plugin https://github.com/zsh-users/zsh-autosuggestions.git
