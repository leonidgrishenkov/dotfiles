#!/bin/zsh

# Specify default apps
export EDITOR="nvim"
export TERMINAL="hyper"
export BROWSER="safari"

# XDG Paths
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Announce 265 bit color support
export TERM=xterm-256color

# --------
# BIN PATHS
# --------
# Add local binaries to path
export PATH="$HOME/.local/bin:$PATH"

# --------
# HOMEBREW
# --------
# If `brew` installed
if command -v /opt/homebrew/bin/brew &> /dev/null; then
    # Add to PATH
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    # Configure download output
    export HOMEBREW_NO_EMOJI=1
    # Don't show hints for env vatialbes
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"
    # Add to FPATH completions installed by brew
    FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
fi

# ---------
# OH-MY-ZSH
# ---------
# Path to oh-my-zsh instalation
export ZSH="$HOME/.oh-my-zsh"
# Pat to custom plugins
export ZSH_CUSTOM="$ZSH/custom"
# Path to cache
ZSH_CACHE_DIR="$HOME/.cache/zsh"; [[ ! -d $ZSH_CACHE_DIR ]]; mkdir -p $ZSH_CACHE_DIR
export ZSH_CACHE_DIR=$ZSH_CACHE_DIR
# Main theme
ZSH_THEME="powerlevel10k/powerlevel10k" 
# Autocompletion options
# Display dots (or given format) when waiting for completions 
COMPLETION_WAITING_DOTS="%F{grey}waiting...%f" 
# COMPLETION_WAITING_DOTS="true"
# Use case-sensitive autocompletion
CASE_SENSITIVE=true
# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE=true
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE=false
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY=true

# History of commands
HISTFILE="$ZSH_CACHE_DIR/history"
HISTSIZE=10000
SAVEHIST=10000
# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"

# Which plugins is currently used
plugins=(
	vi-mode
	zsh-autosuggestions
    zsh-completions
    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages
    colored-man-pages
    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/command-not-found
    command-not-found
    # https://github.com/laggardkernel/git-ignore
    git-ignore
    # https://github.com/Freed-Wu/zsh-help
    zsh-help
    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/poetry
    poetry
    # https://github.com/zdharma-continuum/fast-syntax-highlighting
    fast-syntax-highlighting
)

# Completions 
FPATH="$ZSH_CUSTOM/plugins/zsh-completions/src:$FPATH"
# Path to completions cache
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"

# Source main oh-my-zsh script
source $ZSH/oh-my-zsh.sh

# Oh-my-zsh updates
# https://github.com/ohmyzsh/ohmyzsh#getting-updates
zstyle ':omz:update' mode auto # Auto update
zstyle ':omz:update' frequency 7 # Check updates every 7 days
zstyle ':omz:update' verbose minimal # Output mode

# -----------------
# OH-MY-ZSH plugins
# -----------------
# --- p10k ---
# Source ~/.p10k.zsh if it exists
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# --- zsh-autosuggestions ---
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Set bindkey to accept currently shown autosuggestion
bindkey '^k' autosuggest-accept

# --- vi-mode ---
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
export KEYTIMEOUT=15

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

# Cursor style
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=1
VI_MODE_CURSOR_VISUAL=2
VI_MODE_CURSOR_INSERT=5
VI_MODE_CURSOR_OPPEND=0

# Enter cmd mode from insert mode
bindkey -M viins jf vi-cmd-mode

# Movements
bindkey -M vicmd j vi-backward-char 
bindkey -M visual j vi-backward-char 
bindkey -M vicmd l vi-down-line-or-history
bindkey -M vicmd k vi-up-line-or-history
bindkey -M vicmd \; vi-forward-char

# ------
# POETRY
# ------
# If `poetry` installed
if command -v poetry &> /dev/null; then
    # Create virtual envs in project
    export POETRY_VIRTUALENVS_IN_PROJECT=true
fi

# ----------
# KUBERNETES
# ----------
# If `kubectl` installed
if command -v kubectl &> /dev/null; then
    alias k="kubectl"
    KUBECONFPATH="$HOME/.kube" && [[ ! -d $KUBECONFPATH ]] && mkdir -p $KUBECONFPATH
    export KUBECONFIG="$KUBECONFPATH/smlt-bdd-config.yaml"
fi

# ----------
# YANDEX-CLOUD
# ----------
# If CLI utility `yc` installed source completions
if command -v yc &> /dev/null; then
    source \
    $(brew info --cask yandex-cloud-cli --json=v2 \
    | jq -r '.casks[].artifacts[] | select(.uninstall? // empty) | .uninstall[].delete')/completion.zsh.inc
fi

# -------
# ALIASES
# -------
alias cat="bat --style=plain --theme=Nord --color=always --decorations=always"
alias grep="rg --color=always"

alias ls="exa --all --oneline --icons --group-directories-first"
alias ll="exa --all --long --icons --group-directories-first --created --modified --header --binary --time-style long-iso"
alias tree="exa --tree --all --icons --group-directories-first --ignore-glob='.git*|.venv*|__pycache__*'"

alias vim=$EDITOR
alias v=$EDITOR

# git aliases
alias g="git"
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git pull"
alias gp="git push"
