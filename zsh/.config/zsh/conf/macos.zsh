# === Homebrew ===
eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_NO_ENV_HINTS=1 # Don't show hints for env vatialbes
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1  # disables statistics that brew collects

export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

# === VI mode ===
# https://github.com/jeffreytse/zsh-vi-mode
source "$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

# === Autosuggestions ===
# https://github.com/zsh-users/zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# === Syntax Highlighting ===
# 'fast-syntax-highlighting' has a better appearance but takes ~0.1 sec on startup.
# Repo: https://github.com/zdharma-continuum/fast-syntax-highlighting
source "$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
# Set particular theme.
# To list all themes: fast-theme --list
# To test particular theme in current terminal: fast-theme --test <name>
fast-theme -q "safari"

# 'zsh-syntax-highlighting' quite old plugin but loads much faster then 'fast-syntax-highlighting'.
# Repo: https://github.com/zsh-users/zsh-syntax-highlighting
# source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# === Zellij ===
alias zj="zellij"

# === 1password CLI ===
# eval "$(op completion zsh)"

# === Yandex Cloud CLI ===
# export PATH="$HOME/.yandex-cloud/bin:${PATH}" # Path to binary
# if [ -f "$HOME/.yandex-cloud/completion.zsh.inc" ]; then # Enable zsh completions
#     source "$HOME/.yandex-cloud/completion.zsh.inc"
# fi
