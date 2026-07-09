# vim: set filetype=fish:

# Starship prompt
set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship/starship.zsh.toml"
starship init fish | source
