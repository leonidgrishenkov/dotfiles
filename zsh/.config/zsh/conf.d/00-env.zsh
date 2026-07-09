# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

export DOTFILES_DIR="$HOME/Code/dotfiles"

# === vivid ===
# vivid provides themes for LS_COLORS.
# https://github.com/sharkdp/vivid
export LS_COLORS=$(vivid generate catppuccin-mocha)

# === Rip Grep ===
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"

# === Python ===
export IPYTHONDIR=$XDG_CONFIG_HOME/ipython

# For uv tools
export PATH="$XDG_DATA_HOME/../bin:$PATH"

# === docker ===
export DOCKER_CLI_HINTS=false # disable ads in CLI

# === JQ ===
# https://jqlang.org/manual/#colors
export JQ_COLORS="0;90:0;35:0;35:0;31:0;32:0;39:0;39:0;34"

# === PI Coding Agent ===
export PI_SKIP_VERSION_CHECK=1 # disables version check on startups
export PI_OFFLINE=1            # disables all startup network operations

# === Golang ===
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH="$PATH:$GOBIN"

# === Rust ===
export PATH="$PATH:$HOME/.cargo/bin"
