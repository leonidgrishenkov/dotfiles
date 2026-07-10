# vim: set filetype=fish:

test "$SYSTEM" != Darwin; and return 0

# === Homebrew ===
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

# === Terminal title ===
# Zellij reads the terminal title and uses it for pane names.
# fish calls fish_title automatically: $argv[1] is the running command
# (empty when at the prompt).
function fish_title
    set -l dir (string replace -r -- "^$HOME" "~" "$PWD")
    if test -n "$argv[1]"
        echo "$argv[1] | $dir"
    else
        echo $dir
    end
end

# === DataGrip ===
# Run DataGrip from the shell.
# https://www.jetbrains.com/help/datagrip/working-with-the-ide-features-from-command-line.html#standalone
function datagrip
    open -a "DataGrip.app" --args $argv
end

# === Docker Desktop ===
# Find docker-related executables installed by Docker Desktop.
fish_add_path /Applications/Docker.app/Contents/Resources/bin

abbr -a yccl "yc compute instance list"

# YC completions are quite expensive to load on each shell startup,
# so load them manually when necessary.
function enable-yc
    echo "Loading yc completions"
    yc completion fish | source
    echo "Done. yc completions loaded."
end

# === Obsidian ===
# To be able to use obsidian CLI
fish_add_path /Applications/Obsidian.app/Contents/MacOS

# === OrbStack ===
# Add path to binary and enable shell completions (fish init just adds the path).
source ~/.orbstack/shell/init2.fish 2>/dev/null

# === GPG ===
if status --is-interactive
    set -gx GPG_TTY (tty)
end

# === 1Password ===
# op doesn't generate a fish plugin file, so create wrapper functions
# dynamically for each enabled plugin.
set -l op_used_items "$XDG_CONFIG_HOME/op/plugins/used_items"
if test -d "$op_used_items"
    for f in $op_used_items/*.json
        set -l p (basename $f .json)
        alias $p "op plugin run -- $p"
    end
end
# Completions for op itself
op completion fish | source

alias tldr="tldr --config-path=$HOME/.config/tealdeer/config.toml"
