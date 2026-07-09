# vim: set filetype=fish:

# Homebrew setup — must run before tool inits (10+) that depend on brew binaries.
# Fish equivalent of `brew shellenv`.

set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin

set -gx INFOPATH "/opt/homebrew/share/info:$INFOPATH"

set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_BUNDLE_FILE "$DOTFILES_DIR/brew/.Brewfile"
set -gx HOMEBREW_CACHE "$XDG_CACHE_HOME/homebrew"
