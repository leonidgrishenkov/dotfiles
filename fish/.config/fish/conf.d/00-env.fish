# vim: set filetype=fish:

# === Editor ===
set -gx EDITOR "nvim"
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR

# === Rip Grep ===
set -gx RIPGREP_CONFIG_PATH "$XDG_CONFIG_HOME/ripgrep/.ripgreprc"

# === Python ===
set -gx IPYTHONDIR "$XDG_CONFIG_HOME/ipython"

# === Docker ===
set -gx DOCKER_CLI_HINTS false

# === JQ ===
set -gx JQ_COLORS "0;90:0;35:0;35:0;31:0;32:0;39:0;39:0;34"

# === PI Coding Agent ===
set -gx PI_SKIP_VERSION_CHECK 1
set -gx PI_OFFLINE 1

# === PATH additions ===

# uv tools
if test -d "$XDG_DATA_HOME/../bin"
    fish_add_path "$XDG_DATA_HOME/../bin"
end

# Go
set -gx GOPATH "$HOME/.go"
set -gx GOBIN "$GOPATH/bin"
if test -d "$GOBIN"
    fish_add_path "$GOBIN"
end

# Rust
if test -d "$HOME/.cargo/bin"
    fish_add_path "$HOME/.cargo/bin"
end
