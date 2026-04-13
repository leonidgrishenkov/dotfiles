set -o vi

export PS1="$ "

export EDITOR="nvim"
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.bash.toml" # Set path to config file
eval "$(starship init bash)"
