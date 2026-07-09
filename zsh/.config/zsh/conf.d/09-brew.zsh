# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# Must run before tool inits (10+) that depend on brew-installed binaries.
[[ $SYSTEM != "Darwin" ]] && return 0

eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_NO_ENV_HINTS=1  # Don't show hints for env variables
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1                             # disables statistics that brew collects
export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/brew/.Brewfile" # path to bundle file
export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"
