# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# === bat ===
# https://github.com/sharkdp/bat

# Use bat to show man pages output.
# https://github.com/sharkdp/bat#man
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

# Use bat to show help pages output.
# https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
