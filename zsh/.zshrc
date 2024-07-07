#!/bin/zsh
# vim: set filetype=zsh:
# vim: set ts=4 sw=4 et:

# XDG Paths
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Announce 265 bit color support
export TERM=xterm-256color
# export TERM=screen-256color

export SYSTEM="$(uname -s)"

[[ ! -z $EDITOR ]] || export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'

# --------------------
# `brew` configuration
# --------------------
# If `brew` installed
if command -v /opt/homebrew/bin/brew &>/dev/null; then
    # Export all `brew` env vars. See `man brew` + `/shellenv`
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # No emoji in download output
    # export HOMEBREW_NO_EMOJI=1
    export HOMEBREW_INSTALL_BADGE=""

    # Don't show hints for env vatialbes
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

    # Add to FPATH completions installed by brew
    FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
    # TODO: Does we need here this command?
    # autoload -U compinit
    # compinit
fi

# Set one of the editor as `$EDITOR`
EDITORS="nvim,vim,vi"
for editor in $(echo $EDITORS | sed "s/,/ /g"); do
    if command -v $editor &>/dev/null; then
        export EDITOR=$editor
        break
    fi
done
# Send message if no one editor is installed
[[ ! -z $EDITOR ]] || echo "No editor is installed" >&2

export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export PAGER="less"
# export OPENER= ?
alias v=$EDITOR

# Enable `cargo`
source "$HOME/.cargo/env"

# If we are on linux machine add alias for batcat to be consistent with usage on  macos.
if [[ $SYSTEM = "Linux" ]]; then
    alias bat="batcat"
fi

if command -v bat &>/dev/null; then
    # https://github.com/sharkdp/bat

    # Set zsh-syntax-highlighting theme
    export BAT_THEME="catppuccin-frappe"
    # Setup output elements to show
    export BAT_STYLE="header,numbers,grid"
    # Don't show long outputs as pager
    export BAT_PAGING="never"

    # Use bat to show man pages output.
    # https://github.com/sharkdp/bat#man
    export MANPAGER="sh -c 'col -bx | bat --language=man --style=plain'"

    # Use bat to show help pages output.
    # https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

fi

if command -v rg &>/dev/null; then
    alias gr="rg --color=always"
fi

if command -v eza &>/dev/null; then
    alias ls="eza --all --oneline --icons --group-directories-first"
    alias ll="eza --all --long --icons --group-directories-first --created --modified --header --binary --time-style long-iso"
    alias tree="eza --tree --all --icons --group-directories-first --ignore-glob='.git*|.venv*|__pycache__*|.DS_store'"
fi

# https://github.com/noahgorstein/jqp?tab=readme-ov-file#configuration
if command -v jqp &>/dev/null; then
    alias jqp="jqp --theme catppuccin-frappe"
fi

# ----------------------
# `zinit` configurations
# https://github.com/zdharma-continuum/zinit
# ----------------------
# Install zinit if it doesn't installed and create its direcory
ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Activate zinit
source "${ZINIT_HOME}/zinit.zsh"

# Path to zsh cache
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
# If it doesn't exists create one
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR

# Path to completions cache
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"

# Install plugins for ZSH via zinit
# https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-completions
zinit light zsh-users/zsh-completions
# https://github.com/zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions
# https://github.com/Aloxaf/fzf-tab
zinit light Aloxaf/fzf-tab


# Install plugins from oh-my-zsh repo.
# Enable vim mode support in CLI
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
zinit snippet OMZP::vi-mode
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Autocompletion options
# Display dots (or given format) when waiting for completions
COMPLETION_WAITING_DOTS="%F{grey}waiting...%f"
# COMPLETION_WAITING_DOTS="true"
# Use case-sensitive autocompletion
CASE_SENSITIVE=true
# Auto set terminal tab title
DISABLE_AUTO_TITLE=true
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE=false
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY=true

# Commands history settings
# Number of commands that will be stored in history file
HISTSIZE=2000
# Path to history file
HISTFILE="$ZSH_CACHE_DIR/history"
SAVEHIST=$HISTSIZE
# Erase duplicates in history file
HISTDUP=erase
# History options for zsh
# Appned commands into history file instead of overwrite them
setopt appendhistory
# Share history across all zsh sessions
setopt sharehistory
# Don't write to history commands with space before it.
# NOTE: This is usefull to prevent any sensetive command to be
# written into history file.
setopt hist_ignore_space
# All 3 commands below will prevent zsh to save and store
# duplicates in history file.
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
# Don't show duplicates into prompt when cycle thought them.
setopt hist_find_no_dups

alias h="history | tail -n 50"

# Cycle thought history competions
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"


# Add colors for cd into directory competions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Completions should be case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls $realpath'

# ----------
# `starship`
# ----------
# Init starship
#
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
    # Set var with path to config file
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
fi

# -------
# `yazi`
# -------
# Use `yy` as shell command wrapper that provides the ability
# to change the current working directory when exiting Yazi.
# Took from utility doc: https://yazi-rs.github.io/docs/quick-start#shell-wrapper
if command -v yazi &>/dev/null; then
    function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# --------
# `zoxide`
# --------
# Init zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# ------
# `fzf`
# ------
# Initialize `fzf`
# https://github.com/junegunn/fzf
if command -v fzf &>/dev/null; then
    # Set up fzf key bindings and fuzzy completion
    # https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
    source <(fzf --zsh)

    # https://github.com/junegunn/fzf#layout
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=sharp --margin=0,1,0,1%"

    # Options to fzf command
    export FZF_COMPLETION_OPTS='--border --info=inline'

    function _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
            export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview 'bat --style=plain --color=always {}' "$@" ;;
        esac
    }
fi

# ---------------------------------
# zsh plugins configuration
# ---------------------------------
# `zsh-autosuggestions`
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
# Set bindkey to accept currently shown autosuggestion
bindkey '^k' autosuggest-accept

# `vi-mode`
export KEYTIMEOUT=15
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
# Cursor style
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=1
VI_MODE_CURSOR_VISUAL=2
VI_MODE_CURSOR_INSERT=5
VI_MODE_CURSOR_OPPEND=0
# Keymappings
# Enter cmd mode from insert mode
bindkey -M viins jf vi-cmd-mode
# Movements
bindkey -M vicmd j vi-backward-char
bindkey -M visual j vi-backward-char
bindkey -M vicmd l vi-down-line-or-history
bindkey -M vicmd k vi-up-line-or-history
bindkey -M vicmd \; vi-forward-char


if command -v lazygit &>/dev/null; then
    alias g="lazygit"
fi

if command -v zellij &>/dev/null; then
    alias zj="zellij"
fi


# -----------------------
# `kubectl` configuration
# -----------------------
# If `kubectl` installed
if command -v kubectl &>/dev/null; then

  alias kube="kubectl"

  export KUBECONFIG="$HOME/.kube/smlt-bdd-config.yaml"
  # If config dir doesn't exists create one
  [[ -d $KUBECONFIG:h ]] || mkdir -p $KUBECONFIG:h
fi

# -------------------------------
# Yandex Cloud `yc` configuration
# -------------------------------
# If CLI utility `yc` installed source completions
if command -v yc &>/dev/null; then

  if command -v brew &>/dev/null; then # Check if we use `brew`
    source \
      $(brew info --cask yandex-cloud-cli --json=v2 |
        jq -r '.casks[].artifacts[] | select(.uninstall? // empty) | .uninstall[].delete')/completion.zsh.inc
  fi
fi

alias rm="rm -Iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias c="clear"


if [[ $SYSTEM = "Darwin" ]]; then
    # Some often used paths
    export ICLOUDPATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

    # Python
    export PATH=$HOME/.python/3.12.2/bin:$PATH
fi

# Setting over ssh session
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi


# Other
# Don't let > silently overwrite files. To overwrite, use >! instead.
setopt NO_CLOBBER

# Use modern file-locking mechanisms, for better safety & performance.
# setopt HIST_FCNTL_LOCK

# Check if running on macOS, otherwise stop here
# [[ ! "x$SYSTEM" == "xDarwin" ]] && return
