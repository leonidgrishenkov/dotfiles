# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# === VI mode ===
# https://github.com/jeffreytse/zsh-vi-mode
source $XDG_DATA_HOME/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Yank to system clipboard
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jf
# when invoking command line editing with 'vv'
ZVM_VI_EDITOR=$EDITOR

# === Autosuggestions ===
# https://github.com/zsh-users/zsh-autosuggestions
source $XDG_DATA_HOME/zsh-autosuggestions/zsh-autosuggestions.zsh

# https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#suggestion-strategy
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
# Key to accept currently shown autosuggestion.
# more about autosuggest keymaps here: https://github.com/zsh-users/zsh-autosuggestions?tab=readme-ov-file#key-bindings
bindkey '^F' autosuggest-accept

# === Syntax Highlighting ===
# https://github.com/zdharma-continuum/fast-syntax-highlighting
source $XDG_DATA_HOME/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# === Additional ZSH completions ===
# https://github.com/zsh-users/zsh-completions
source $XDG_DATA_HOME/zsh-completions/zsh-completions.plugin.zsh
