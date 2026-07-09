# vim: set filetype=fish:

# Use bat as man pager (strip ANSI then pipe to bat)
set -gx MANPAGER "sh -c 'awk \"{ gsub(/\\x1B\\[[0-9;]*m/, \\\"\\\", \\\$0); gsub(/.\\x08/, \\\"\\\", \\\$0); print }\" | bat -p -lman'"

# Pipe --help through bat for syntax highlighting
# https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'
