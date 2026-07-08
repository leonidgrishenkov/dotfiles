#!/usr/bin/env zsh
# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

if [[ -d "$ZDOTDIR/conf" ]]; then
    files=($ZDOTDIR/conf/*.zsh(N))
    for file in $files; do
        source "$file"
    done
fi

export FPATH="$FPATH:$XDG_DATA_HOME/zsh/site-functions"

# === vivid ===
# vivid provides themes for LS_COLORS.
# https://github.com/sharkdp/vivid
export LS_COLORS=$(vivid generate catppuccin-mocha)

# === Rip Grep ===
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"

# === Starship ===
# Set path to config file
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.zsh.toml"
eval "$(starship init zsh)"

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

_show_file_preview="bat -pp --line-range :500 --force-colorization {}"
_show_dir_preview="eza --tree --icons --all --color=always {} | head -200"
_show_file_or_dir_preview="if [ -d {} ]; then $_show_dir_preview; else $_show_file_preview; fi"

function _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    vim | nvim | v | code | open) fzf --preview "$_show_file_or_dir_preview" "$@" ;;
    ls | eza | cd) fd --type d -H -E .git | fzf --preview "$_show_dir_preview" "$@" ;;
    cat | bat) fd --type f -H -E .git | fzf --preview "$_show_file_preview" "$@" ;;
    export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh | telnet) fzf --preview 'dig {}' "$@" ;;
    kill | pkill) fzf --preview 'ps -f -p {}' --preview-window=down:3:wrap "$@" ;;
    *) fzf "$@" ;;
    esac
}

# === Python ===
# IPython configurations dir
export IPYTHONDIR=$XDG_CONFIG_HOME/ipython

# For uv tools
export PATH="$XDG_DATA_HOME/../bin:$PATH"

# === docker ===
export DOCKER_CLI_HINTS=false # disable ads in CLI

# === atuin ===
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# === zoxide ===
eval "$(zoxide init zsh)"

# === PI Coding Agent ===
export PI_SKIP_VERSION_CHECK=1 # disables version check on startups
export PI_OFFLINE=1            # disables all startup network operations

# === JQ ===
# https://jqlang.org/manual/#colors
export JQ_COLORS="0;90:0;35:0;35:0;31:0;32:0;39:0;39:0;34"

function command_not_found_handler() {
    print -P "%F{red} %fcommand not found: $1"
    return 127
}

# === Golang ===
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH="$PATH:$GOBIN"

# === Rust ===
export PATH="$PATH:$HOME/.cargo/bin"

# === direnv ===
eval "$(direnv hook zsh)"

# zsh-vi-mode overrides keybindings after it loads, including ^r binding for atuin. In order to avoid it here I use
# zvm_after_init hook that zsh-vi-mode provides. This hook runs after zsh-vi-mode finishes setting up its
# keybindings, so my custom bindings won't get overwritten.
function zvm_after_init() {
    # https://docs.atuin.sh/configuration/key-binding/#zsh
    bindkey '^r' atuin-search
    bindkey -M vicmd '^r' atuin-search-vicmd
}

if [[ -d "$ZDOTDIR/extra" ]]; then
    files=($ZDOTDIR/extra/*.zsh(N))
    for file in $files; do
        source "$file"
    done
fi

autoload -Uz compinit
compinit -i
