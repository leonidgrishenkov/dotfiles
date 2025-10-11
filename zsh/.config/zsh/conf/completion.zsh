# vivid provides themes for LS_COLORS.
# Repo: https://github.com/sharkdp/vivid
export LS_COLORS=$(vivid generate catppuccin-mocha)

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

