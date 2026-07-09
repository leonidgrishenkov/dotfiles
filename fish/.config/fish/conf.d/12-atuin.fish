# vim: set filetype=fish:

# atuin shell integration
atuin init fish --disable-up-arrow | source

# Re-bind Ctrl+R for atuin search (works alongside other tools)
bind \cr _atuin_search
bind -M insert \cr _atuin_search
