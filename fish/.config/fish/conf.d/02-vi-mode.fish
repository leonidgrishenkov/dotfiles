# vim: set filetype=fish:

# Enable vi keybindings
fish_vi_key_bindings

# Custom escape binding: jf instead of Esc
# (bound in command mode to leave insert mode)
bind -M insert jf "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

# Copy to system clipboard in visual mode
bind -M visual y "fish_clipboard_copy"
