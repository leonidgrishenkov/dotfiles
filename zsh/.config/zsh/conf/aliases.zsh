# Basic
alias rm="rm -Iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias h="history | tail -n 50"
alias c="clear"

alias k="kubectl"
alias d="docker"
alias t="terraform"

alias gr="rg --color=always"

alias ls="eza --all --oneline --icons --group-directories-first"
alias ll="eza --all --long --icons --group-directories-first --created --modified --header --binary --time-style long-iso"
alias tree="eza --tree --all --icons --group-directories-first --ignore-glob='.git*|.venv*|__pycache__*|.DS_store'"

alias v=$EDITOR
