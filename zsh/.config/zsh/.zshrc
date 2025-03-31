#!/bin/zsh
# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

[[ ! -z $EDITOR ]] || export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'

# Set one of the editor as $EDITOR
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
# Use nvim as man pager:
# export MANPAGER="nvim +Man!"
alias v=$EDITOR


# ========= zinit =========
#
# Repo: https://github.com/zdharma-continuum/zinit
#
# Install zinit if it doesn't installed and create its directory
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
# BUG: This doesn't work, cache stores in ~/.config/zsh/ directory
ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"

# Install zsh plugins via zinit
#
# https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting

# https://github.com/zsh-users/zsh-completions
zinit light zsh-users/zsh-completions

# https://github.com/zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions

# https://github.com/Aloxaf/fzf-tab
zinit light Aloxaf/fzf-tab

# Install plugins from oh-my-zsh repo.
#
# Enable vim mode support in CLI
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
zinit snippet OMZP::vi-mode

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# ========= Autocompletion options =========
#
# Display dots (or given format) when waiting for completions
COMPLETION_WAITING_DOTS="%F{grey}waiting...%f"

# COMPLETION_WAITING_DOTS="true"
# Use case-sensitive autocompletion
CASE_SENSITIVE=true

# Auto set terminal tab title
DISABLE_AUTO_TITLE=false

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE=false

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY=true

# Add colors for cd into directory competions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completions should be case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# ========= History settings =========
#
# Number of commands that will be stored in history file
HISTSIZE=10000

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
# This is usefull to prevent any sensetive command to be written into history file.
setopt hist_ignore_space

# All 3 commands below will prevent zsh to save and store duplicates in history file.
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Don't show duplicates into prompt when cycle thought them.
setopt hist_find_no_dups

# Don't let > silently overwrite files. To overwrite, use >! instead.
setopt no_clobber

# Use modern file-locking mechanisms, for better safety & performance.
setopt hist_fcntl_lock

# Cycle thought history competions
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"


source "$XDG_CONFIG_HOME/shell/aliases"
source "$XDG_CONFIG_HOME/shell/tools/common"
source "$XDG_CONFIG_HOME/shell/tools/lang"

if [[ $SYSTEM = "Darwin" ]]; then
    source "$XDG_CONFIG_HOME/shell/tools/macos"
fi

# ========= zsh plugins configuration =========
# zsh-autosuggestions:
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
# Set bindkey to accept currently shown autosuggestion
bindkey '^k' autosuggest-accept

# ========= Vim mode =========
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
bindkey -M vicmd h vi-backward-char
bindkey -M visual h vi-backward-char
bindkey -M vicmd j vi-down-line-or-history
bindkey -M vicmd k vi-up-line-or-history
bindkey -M vicmd l vi-forward-char
bindkey -M vicmd ee edit-command-line


update_zellij_pane_name() {
    # https://www.reddit.com/r/zellij/comments/10skez0/does_zellij_support_changing_tabs_name_according/?rdt=58606
    # If we are inside zellij
    if [[ -n $ZELLIJ ]]; then
        local _current_dir=$PWD

        if [[ $_current_dir == $HOME ]]; then
            local _pane_name="~"
        else
            # TODO: add less short substitution
            # _pane_name="../${_current_dir##*/}"
            local _pane_name=$_current_dir
        fi

        # TODO: this doesn't work
        if [[ -n $SSH_CONNECTION ]]; then
            _pane_name="ssh-test"
        fi

        command nohup zellij action rename-pane $_pane_name >/dev/null 2>&1
    fi
}

# zellij multiplexor
# if command -v zellij &>/dev/null; then
    # Add hook to invoke func to update zellij pane name.
    # autoload -U add-zsh-hook
    # add-zsh-hook chpwd update_zellij_pane_name
# fi

