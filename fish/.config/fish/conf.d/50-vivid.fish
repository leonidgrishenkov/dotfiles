# vim: set filetype=fish:

# === vivid ===
# LS_COLORS theme for ls/eza color output
# https://github.com/sharkdp/vivid
if command -q vivid
    set -gx LS_COLORS (vivid generate catppuccin-mocha)
end
