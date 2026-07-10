# vim: set filetype=fish:

# Enable vi keybindings
fish_vi_key_bindings

# Accept the full autosuggestion line (Ctrl+F)
bind -M insert \cf accept-autosuggestion

# Custom escape binding: jf instead of Esc
# (bound in command mode to leave insert mode)
bind -M insert jf "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

# Open command line buffer in $EDITOR (vi command mode: vv)
bind -M default vv edit_command_buffer

# Copy to system clipboard in visual mode
bind -M visual y "fish_clipboard_copy"
