# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# Rebuild completion dump. Must run after all plugins are sourced
# (zsh-completions adds to fpath, so compinit needs to see it).
autoload -Uz compinit
compinit -i
