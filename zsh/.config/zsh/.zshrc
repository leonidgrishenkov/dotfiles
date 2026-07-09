#!/usr/bin/env zsh
# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# Source all conf.d files in sorted order
if [[ -d "$ZDOTDIR/conf.d" ]]; then
    files=($ZDOTDIR/conf.d/*.zsh(N))
    for file in $files; do
        source "$file"
    done
fi

# Source extra overrides (user-specific, machine-specific, etc.)
if [[ -d "$ZDOTDIR/extra.d" ]]; then
    files=($ZDOTDIR/extra.d/*.zsh(N))
    for file in $files; do
        source "$file"
    done
fi

# Report unknown commands
function command_not_found_handler() {
    print -P "%F{red} %fcommand not found: $1"
    return 127
}
