# vim: set filetype=fish:

# Use bat as man pager (strip ANSI then pipe to bat)
set -gx MANPAGER "sh -c 'awk \"{ gsub(/\\x1B\\[[0-9;]*m/, \\\"\\\", \\\$0); gsub(/.\\x08/, \\\"\\\", \\\$0); print }\" | bat -p -lman'"

# Pipe --help through bat for syntax highlighting
abbr -a -- -h '-h 2>&1 | bat --language=help --style=plain'
abbr -a -- --help '--help 2>&1 | bat --language=help --style=plain'
