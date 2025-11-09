#!/bin/sh

echo "Installing zsh plugins"

if [ -z "$XDG_DATA_HOME" ]; then
    echo 'XDG_DATA_HOME env var is required'
    exit 1
fi

echo "Installing zsh-vi-mode"
if [ -d "$XDG_DATA_HOME/zsh-vi-mode" ]; then
    echo "zsh-vi-mode already installed, pulling"
    cd "$XDG_DATA_HOME/zsh-vi-mode"
    git pull
else
    git clone https://github.com/jeffreytse/zsh-vi-mode.git "$XDG_DATA_HOME/zsh-vi-mode"
fi

echo "Installing zsh-autosuggestions"
if [ -d "$XDG_DATA_HOME/zsh-autosuggestions" ]; then
    echo "zsh-autosuggestions already installed, pulling"
    cd "$XDG_DATA_HOME/zsh-autosuggestions"
    git pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$XDG_DATA_HOME/zsh-autosuggestions"
fi

echo "Installing fast-syntax-highlighting"
if [ -d "$XDG_DATA_HOME/fast-syntax-highlighting" ]; then
    echo "fast-syntax-highlighting already installed, pulling"
    cd "$XDG_DATA_HOME/fast-syntax-highlighting"
    git pull
else
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$XDG_DATA_HOME/fast-syntax-highlighting"
fi
