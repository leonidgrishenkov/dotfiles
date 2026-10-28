# vim: set filetype=fish:

test "$SYSTEM" != Linux; and return 0

# === Mise ===
mise activate fish | source

# === direnv ===
direnv hook fish | source
