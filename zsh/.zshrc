#!/bin/zsh

# XDG Paths
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Announce 265 bit color support
export TERM=xterm-256color

export SYSTEM="$(uname -s)"

[[ ! -z $EDITOR ]] || export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'

# --------------------
# `brew` configuration
# --------------------
# If `brew` installed
if command -v /opt/homebrew/bin/brew &> /dev/null; then
    # Export all `brew` env vars. See `man brew` + `/shellenv`
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # No emoji in download output
    # export HOMEBREW_NO_EMOJI=1
    export HOMEBREW_INSTALL_BADGE="💣"

    # Don't show hints for env vatialbes
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

    # Add to FPATH completions installed by brew
    FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
    autoload -U compinit
    compinit
fi

# Set one of the editor as `$EDITOR`
EDITORS="nvim,vim,vi"
for editor in $(echo $EDITORS | sed "s/,/ /g"); do
    if command -v $editor &> /dev/null; then
        export EDITOR=$editor
        break
    fi
done
# Send message if no one editor is installed
[[ ! -z $EDITOR ]] || echo "No editor is installed" >&2

export TERMINAL="iterm"
export BROWSER="safari"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
# export OPENER= ?

# Change manpager to `bat`. Took from: https://github.com/sharkdp/bat#man
export MANPAGER="sh -c 'col -bx | bat --language=man --style=plain --theme=Nord --color=always --decorations=always'"

# -------------------------
# `oh-my-zsh` configuration
# -------------------------
# Path to oh-my-zsh instalation
export ZSH="$HOME/.oh-my-zsh"

# Pat to custom plugins
export ZSH_CUSTOM="$ZSH/custom"

# Path to zsh cache
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
# If it doesn't exists create one
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR

# zsh theme
ZSH_THEME="powerlevel10k/powerlevel10k"

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

# History of commands
HISTFILE="$ZSH_CACHE_DIR/history"
HISTSIZE=10000
SAVEHIST=10000
# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"

# Which plugins is currently used
plugins=(
    # Enable vim mode support in CLI
    # Repo: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
	vi-mode

    # Repo: https://github.com/zsh-users/zsh-autosuggestions
	zsh-autosuggestions

    # Docs: https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
    # Repo: https://github.com/zsh-users/zsh-completions
    zsh-completions

    # CLI commands syntax highlighting.
    # Repo: https://github.com/zsh-users/zsh-syntax-highlighting
    zsh-syntax-highlighting

    # Add colors for man pages
    # Repo: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages
    # colored-man-pages

    # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/command-not-found
    command-not-found # BUG: Is this works?

    # Generate `.gitignore` files.
    # Usage: `git-ignore` + <Enter>
    # Repo: https://github.com/laggardkernel/git-ignore
    git-ignore

    # Add colors for help pages. Default only for `--help`.
    # Repo: https://github.com/Freed-Wu/zsh-help
    zsh-help

    # CLI commands syntax highlight with themes.
    # Repo: https://github.com/zdharma-continuum/fast-syntax-highlighting
    # Usage: `fast-theme --help`
    # fast-syntax-highlighting

    # Change behevior of terminal titles generation
    # Repo: https://github.com/trystan2k/zsh-tab-title
    # zsh-tab-title
)

if [[ $SYSTEM = "Darwin" ]]; then

    # Usefull commands for macos
    # Repo: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
    # All commands: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos#commands
    plugins+=(macos) # Add to oh-my-zsh plugins list
fi

# If `poetry` installed
if command -v poetry &> /dev/null; then
    # Create virtual envs in project
    export POETRY_VIRTUALENVS_IN_PROJECT=true

    # Autocompletions for `poetry`.
    # Repo: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/poetry
    plugins+=(poetry)
fi


if command -v fzf &> /dev/null; then

    # For integrations with `fzf`
    # Repo: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf
    plugins+=(fzf)

    # Repo: https://github.com/junegunn/fzf#layout
    # Docs: `man fzf`
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=sharp --margin=0,1,0,1%"
fi


# Completions for apps
FPATH="$ZSH_CUSTOM/plugins/zsh-completions/src:$FPATH"

# Path to completions cache
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"

# Source main `oh-my-zsh.sh`
source $ZSH/oh-my-zsh.sh

# `oh-my-zsh` updates
# https://github.com/ohmyzsh/ohmyzsh#getting-updates
zstyle ':omz:update' mode auto # Auto update
zstyle ':omz:update' frequency 7 # Check updates every 7 days
zstyle ':omz:update' verbose minimal # Output mode

# ---------------------------------
# `oh-my-zsh` plugins configuration
# ---------------------------------
# `p10k`
# Wiki: https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt

# All settings should be after source config file
POWERLEVEL9K_CONFIG_FILE="$XDG_CONFIG_HOME/p10k/.p10k.zsh"
[[ ! -f $POWERLEVEL9K_CONFIG_FILE ]] || source $POWERLEVEL9K_CONFIG_FILE

# Remove os icon from left side of prompt
unset 'POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[1]'

# Disable configuration wizard auto prompt
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

POWERLEVEL9K_MODE=nerdfont-complete

# show Python version next to the virtual environment name.
POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
# Hide python version if it doesn't come from one of these sources.
POWERLEVEL9K_PYENV_SOURCES=(shell local global)

# Define/remap icons
POWERLEVEL9K_VCS_GIT_ICON="󰊢"
# POWERLEVEL9K_VCS_GIT_GITLAB_ICON="󰮠"

# Insert mode icons
POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION=""
# TODO maybe add diferent color for error sybmol?
POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION=""

POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION=""
POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION=""

POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_CONTENT_EXPANSION=""
POWERLEVEL9K_PROMPT_CHAR_ERROR_VIVIS_CONTENT_EXPANSION=""

# Display path behaviour
# https://stackoverflow.com/questions/61176257/customizing-powerleve10k-prompt
# Max symbols to show
# POWERLEVEL9K_DIR_MAX_LENGTH=20
# If directory is too long, shorten some of its segments to the
# shortest possible unique prefix. The shortened directory can be
# tab-completed to the original.
#   - `truncate_to_unique` - Default value
#   - `truncate_to_last` - Show only the last directory segment.
# POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"

# `zsh-help`
# Redifine `--help` output appearence.
# Took from: https://github.com/Freed-Wu/zsh-help#function--help
-help() {
    bat --language=help --style=plain --theme=Nord --color=always --decorations=always
}

# `zsh-autosuggestions`
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=249"
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

# `zsh-tab-title`
# ZSH_TAB_TITLE_DISABLE_AUTO_TITLE=true
# Prefix for title. Doesn't work for some reason.
# ZSH_TAB_TITLE_PREFIX="$USER@$HOST: "
# Enable to show the full command being run without
# it's arguments in the tab title.
# For example, `nano .zshrc` will show 'nano .zshrc'
# instead of just 'nano'. Default is to display only
# the command without it's arguments
# ZSH_TAB_TITLE_ENABLE_FULL_COMMAND=true
# Show only folder name insted of full path to pwd
# ZSH_TAB_TITLE_ONLY_FOLDER=true

# -----------------------
# `kubectl` configuration
# -----------------------
# If `kubectl` installed
if command -v kubectl &> /dev/null; then

    alias kube="kubectl"

    export KUBECONFIG="$HOME/.kube/smlt-bdd-config.yaml"
    # If config dir doesn't exists create one
    [[ -d $KUBECONFIG:h ]] || mkdir -p $KUBECONFIG:h
fi

# -------------------------------
# Yandex Cloud `yc` configuration
# -------------------------------
# If CLI utility `yc` installed source completions
if command -v yc &> /dev/null; then

    if command -v brew &> /dev/null; then # Check if we use `brew`
        source \
        $(brew info --cask yandex-cloud-cli --json=v2 \
        | jq -r '.casks[].artifacts[] | select(.uninstall? // empty) | .uninstall[].delete')/completion.zsh.inc
    fi
fi

# -------
# Aliases
# -------
# About `bat` and more features: https://github.com/sharkdp/bat
alias cat="bat --style=plain --theme=Nord --color=auto --decorations=auto"

alias gr="rg --color=always"

alias ls="eza --all --oneline --icons --group-directories-first"
alias ll="eza --all --long --icons --group-directories-first --created --modified --header --binary --time-style long-iso"
alias tree="eza --tree --all --icons --group-directories-first --ignore-glob='.git*|.venv*|__pycache__*|.DS_store'"

alias v=$EDITOR

alias rmi="rm -Iv"
alias h="history | tail -n 50"
alias cl="clear"

# Aliases for `git`
alias g="git"
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git push"

# Change dir
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Some often use paths
export CONFPATH=$HOME/Code/configs
export CODEPATH=$HOME/Code
export ICLOUDPATH=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs

# Python
export PATH=$HOME/.python/3.12.2/bin:$PATH

# Setting over ssh session
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi

# Extra zsh options
# Don't let > silently overwrite files. To overwrite, use >! instead.
setopt NO_CLOBBER

# Use modern file-locking mechanisms, for better safety & performance.
# setopt HIST_FCNTL_LOCK

# Keep only the most recent copy of each duplicate entry in history.
setopt HIST_IGNORE_ALL_DUPS

# Leave blanks out
setopt HIST_REDUCE_BLANKS

# Auto-sync history between concurrent sessions.
setopt SHARE_HISTORY

# Check if running on macOS, otherwise stop here
# [[ ! "x$SYSTEM" == "xDarwin" ]] && return
#
#
export HI='hi there! My name is dashenka!'
