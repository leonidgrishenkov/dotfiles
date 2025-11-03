#!/usr/bin/env zsh
# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

ERROR='\033[0;31m'   # red color
SUCCESS='\033[0;32m' # green
WARNING='\033[1;33m' # yellow
NORMAL='\033[0m'     # no Color

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

if [[ $SYSTEM = "Darwin" ]]; then
    source "$ZDOTDIR/conf/macos.zsh"
fi

source "$ZDOTDIR/conf/history.zsh"
source "$ZDOTDIR/conf/aliases.zsh"
source "$ZDOTDIR/conf/completion.zsh"

export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"         # Path to zsh cache
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR # If it doesn't exists create one
# BUG: this doesn't work, zsh still dump into ~/.config/zsh/.zcompdump
export ZSH_COMPDUMP="$ZSH_CACHE_DIR" # Path to completions cache file

# === Rip Grep ===
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"

# === Starship ===
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml" # Set path to config file
eval "$(starship init zsh)"

# === zsh-vi-mode ===
# Here are config options. For macos plugin sourced in ./conf/macos.zsh
ZVM_SYSTEM_CLIPBOARD_ENABLED=true # Yank to system clipboard
ZVM_VI_INSERT_ESCAPE_BINDKEY=jf
ZVM_VI_EDITOR=$EDITOR # when invoking command line editing with 'vv'

# === zsh-autosuggestions ===
ZSH_AUTOSUGGEST_STRATEGY=(history) # https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#suggestion-strategy
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
# more about autosuggest keymaps here: https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#key-bindings
bindkey '^F' autosuggest-accept # Key to accept currently shown autosuggestion.

# === YAZI ===
# Use 'y' as shell command wrapper that provides the ability
# to change the current working directory when exiting Yazi.
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# === zoxide ===
eval "$(zoxide init zsh)"

# === bat / batcat ===
# https://github.com/sharkdp/bat

# Use bat to show man pages output.
# https://github.com/sharkdp/bat#man
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

# Use bat to show help pages output.
# https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# === fzf ===
# https://github.com/junegunn/fzf
# https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
source <(fzf --zsh)

# Catppuccin frappe theme, took from here: https://github.com/catppuccin/fzf
# But note that I removed here background color in order to make fzf UI transparent.
export FZF_DEFAULT_OPTS=" \
    --color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
    --color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
    --color=border:#737994,label:#C6D0F5 \
    --style=minimal \
    --cycle \
    --border=rounded"

_show_file_preview="bat -n --line-range :500 {}"
_show_dir_preview="eza --tree --icons --all {} | head -200"
_show_file_or_dir_preview="if [ -d {} ]; then $_show_dir_preview; else $_show_file_preview; fi"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    vim | nvim | v | code | open) fzf --preview "$_show_file_or_dir_preview" "$@" ;;
    ls | eza | cd) fd --type d | fzf --preview "$_show_dir_preview" "$@" ;;
    cat | bat) fd --type f | fzf --preview "$_show_file_preview" "$@" ;;
    export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh | telnet) fzf --preview 'dig {}' "$@" ;;
    kill | pkill) fzf --preview 'ps -f -p {}' --preview-window=down:3:wrap "$@" ;;
    *) fzf "$@" ;;
    esac
}

# === Python ===
# IPython configurations dir
export IPYTHONDIR=~/.config/ipython

function load-python() {
    echo -e "${SUCCESS}Loading Python environment"
    # Load UV completions into shell
    eval "$(uv generate-shell-completion zsh)"

    function load-venv() {
        if [ -d "./.venv" ]; then
            . .venv/bin/activate
            echo -e "${SUCCESS}Virtual environment activated"
        else
            echo -e "${WARNING}No .venv directory found in current directory\!"
            return 1
        fi
    }
}

# === Golang ===
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

# === direnv ===
eval "$(direnv hook zsh)"

# === jqp ===
# https://github.com/noahgorstein/jqp?tab=readme-ov-file#configuration
# alias jqp="jqp --theme catppuccin-frappe"

# === docker ===
export DOCKER_CLI_HINTS=false # disable ads in CLI

# === atuin ===
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# zsh-vi-mode overrides keybindings after it loads, including ^r binding for atuin. In order to avoid it here I use
# zvm_after_init hook that zsh-vi-mode provides. This hook runs after zsh-vi-mode finishes setting up its
# keybindings, so my custom bindings won't get overwritten.
function zvm_after_init() {
    # https://docs.atuin.sh/configuration/key-binding/#zsh
    bindkey '^r' atuin-search
    bindkey -M vicmd '^r' atuin-search-vicmd
}

autoload -Uz compinit
compinit -i
