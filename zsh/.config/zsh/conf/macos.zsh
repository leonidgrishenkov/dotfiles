# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

[[ $SYSTEM != "Darwin" ]] && return 0

# === Homebrew ===
eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_NO_ENV_HINTS=1 # Don't show hints for env vatialbes
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1                             # disables statistics that brew collects
export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/brew/.Brewfile" # path to bundle file

export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

# Configure terminal title updates for Zellij to automatically detect
# Zellij reads the terminal title and uses it for pane names
function precmd() {
    # Set terminal title to current directory when prompt is displayed
    # %~ expands to current directory with ~ for home
    print -Pn "\e]2;%~\a"
}

function preexec() {
    # preexec receives: $1 = typed command, $2 = expanded command (aliases resolved), $3 = after history expansion
    # Use $2 to show the actual command that will run (with aliases expanded)
    local cmd="${2:-$1}" # Fallback to $1 if $2 is empty

    # Show command with current directory: "command args | /any/path"
    # %~ expands to current directory with ~ for home
    print -Pn "\e]2;$cmd | %~\a"
}

# === DataGrip ===
# Run DataGrip from the shell.
# https://www.jetbrains.com/help/datagrip/working-with-the-ide-features-from-command-line.html#standalone
function datagrip() {
    open -a "DataGrip.app" --args "$@"
}

# This helps to find docker related executables installed by docker desktop.
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"

alias yccl="yc compute instance list"

# YC completions are quite expensive to load on each ZSH startup, so I prefer to load it manually when it's necessary.
function enable-yc() {
    echo -e "${SUCCESS}Loading yc completions"

    local cask_name="yandex-cloud-cli"
    local yc_installed_version=$(brew info --cask $cask_name --json=v2 | jq -r '.casks[0].version')

    local comp_source_file="$HOMEBREW_PREFIX/Caskroom/$cask_name/${yc_installed_version}/$cask_name/completion.zsh.inc"

    if [ -f $comp_source_file ]; then
        echo -e "${SUCCESS}Using file: $comp_source_file"
        source $comp_source_file
    else
        echo -e "${ERROR}Can't find completions file. Expected file doen't not exist: $comp_source_file"
    fi
}

# === Obsidian ===
# To be able to use obsidian CLI
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# === OrbStack ===
# Add path to binary into the PATH and enable shell completions
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# === GPG ===
export GPG_TTY=$(tty)

# === 1Password ===
# Shell integrations
if [[ -f "$XDG_CONFIG_HOME/op/plugins.sh" ]]; then
    source ~/.config/op/plugins.sh
fi

export DOTFILES_DIR="$HOME/Code/dotfiles"
