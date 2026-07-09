# Use vim style keybind for prompt editing
set -o vi

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

export XDG_CONFIG_HOME="$HOME/.config"

# === Starship ===
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
eval "$(starship init bash)"
