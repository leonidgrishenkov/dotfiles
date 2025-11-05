#!/usr/bin/env zsh
# vim: set filetype=zsh:
# vim: set ts=4 sw=4 et:

# https://github.com/htr3n/zsh-config/blob/master/zshenv
skip_global_compinit=1
setopt noglobalrcs

export ZDOTDIR="$HOME/.config/zsh" # Path to zsh configurations

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export SYSTEM="$(uname -s)"

if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$ZDOTDIR/.zprofile" ]]; then
  source "$ZDOTDIR/.zprofile"
fi

export DOTFILES_DIR="$HOME/Code/dotfiles"

export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"         # Path to zsh cache
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR # If it doesn't exists create one
