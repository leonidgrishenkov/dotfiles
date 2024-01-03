#!/bin/zsh

# Specify default apps
export EDITOR="nvim"
export TERMINAL="hyper"
export BROWSER="safari"

# Announce 265 bit color support
export TERM=xterm-256color

# --------
# HOMEBREW
# --------
if [[ "$(uname -s)" = "Darwin" ]]; then
    # Add to PATH
    export PATH="/opt/homebrew/opt:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    # Configure download output
    export HOMEBREW_NO_EMOJI=1
    # Don't show hints for env vatialbes
    export HOMEBREW_NO_ENV_HINTS=1
fi

# ---------
# OH-MY-ZSH
# ---------
# Path to oh-my-zsh instalation
export ZSH="$HOME/.oh-my-zsh"
# Path to cache
export ZSH_CACHE_DIR="$ZSH/cache"
# Main theme
ZSH_THEME="powerlevel10k/powerlevel10k" 
# Autocompletion options
# Display dots (or given format) when waiting for completions 
COMPLETION_WAITING_DOTS="%F{grey}waiting...%f" 
# COMPLETION_WAITING_DOTS="true"
# Use case-sensitive autocompletion
CASE_SENSITIVE="false"
# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History of commands
HISTPATH="$HOME/.local/share/zsh" && [[ ! -d $HISTPATH ]] && mkdir -p $HISTPATH
HISTFILE="$HISTPATH/history"
HISTSIZE=100000
SAVEHIST=100000

# Path to completions
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"

# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"

# Which plugins is currently used
plugins=(
	vi-mode
	zsh-syntax-highlighting
	zsh-autosuggestions
)

# Source main oh-my-zsh script if it exists
[[ ! -f $ZSH/oh-my-zsh.sh ]] || source $ZSH/oh-my-zsh.sh

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

# ----------
# KUBERNETES
# ----------
if command kubectl &> /dev/null; then

    alias k="kubectl"

    KUBECONFPATH="$HOME/.kube" && [[ ! -d $KUBECONFPATH ]] && mkdir -p $KUBECONFPATH

    export KUBECONFIG="$KUBECONFPATH/smlt-bdd-config.yaml"
fi 
# Path to kubectl config

# ------------
# YANDEX CLOUD
# ------------
# Add bin to PATH
export PATH="$HOME/.yandex-cloud/bin:$PATH"

# -------
# ALIASES
# -------
alias cat="bat --style=plain --theme=Nord --color=always --decorations=always"
alias ls="exa --icons --group-directories-first"
alias grep="rg --color=always"

alias vim="$EDITOR"
alias v="$EDITOR"

# git aliases
alias g="git"
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git pull"
alias gp="git push"
