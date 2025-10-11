# vivid provides themes for LS_COLORS.
# Repo: https://github.com/sharkdp/vivid
export LS_COLORS=$(vivid generate catppuccin-mocha)

zstyle ':completion:*' menu select
# Use LS_COLORS for completion items.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Limit number of output lines. `LINES` - the number of lines that fit on screen.
# NOTE: -e lets you specify a dynamically generated value.
zstyle -e ':autocomplete:*:*' list-lines 'reply=( $(( LINES / 3 )) )'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true

# Press 'tab' to invoke completion menu and cycle through completion items.
bindkey '^I' menu-complete
# Press 'shift+tab' to cycle through completion items backwards.
bindkey "$terminfo[kcbt]" reverse-menu-complete
