#!/usr/bin/env zsh
# vim: set filetype=zsh:
# vim: set ts=4 sw=4 et:

autoload -Uz compinit

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export PAGER="less"

source "$ZDOTDIR/conf/history.zsh"
source "$ZDOTDIR/conf/aliases.zsh"

if [[ $SYSTEM = "Darwin" ]]; then
    source "$ZDOTDIR/conf/macos.zsh"
fi

export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh" # Path to zsh cache
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
ZSH_AUTOSUGGEST_STRATEGY=(completion history) # https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#suggestion-strategy
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
bindkey '^M' autosuggest-accept # Key to accept currently shown autosuggestion. 'M' stands for Enter key
# more about autosuggest keymaps here: https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#key-bindings

# === YAZI ===
# Use 'y' as shell command wrapper that provides the ability
# to change the current working directory when exiting Yazi.
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
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

# === Python ===
function load-python() {
    echo -e "\033[32mLoading Python environment\033[0m"

    # Load UV completions into shell
    eval "$(uv generate-shell-completion zsh)"
    # IPython configurations dir
    export IPYTHONDIR=~/.config/ipython
}

# === Golang ===
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

# === direnv ===
# eval "$(direnv hook zsh)"

# === jqp ===
# https://github.com/noahgorstein/jqp?tab=readme-ov-file#configuration
# alias jqp="jqp --theme catppuccin-frappe"

# === docker ===
export DOCKER_CLI_HINTS=false  # disable ads in CLI

# === atuin ===
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# https://docs.atuin.sh/configuration/key-binding/#zsh
bindkey '^r' atuin-search
bindkey -M vicmd '^r' atuin-search-vicmd

compinit
