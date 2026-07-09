# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# zsh-vi-mode overrides keybindings after it loads, including ^r binding for
# atuin. Use zvm_after_init hook that zsh-vi-mode provides to re-bind keys
# after the plugin finishes setting up its keybindings.
function zvm_after_init() {
    # https://docs.atuin.sh/configuration/key-binding/#zsh
    bindkey '^r' atuin-search
    bindkey -M vicmd '^r' atuin-search-vicmd
}
