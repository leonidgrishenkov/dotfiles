# vim: set filetype=fish:

test "$SYSTEM" != Linux; and return 0

# === Mise ===
mise activate fish | source
