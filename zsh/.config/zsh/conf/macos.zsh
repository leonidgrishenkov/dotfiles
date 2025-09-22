eval "$(/opt/homebrew/bin/brew shellenv)"

export HOMEBREW_INSTALL_BADGE=""
export HOMEBREW_NO_ENV_HINTS=1 # Don't show hints for env vatialbes
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1  # disables statistics that brew collects

export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

# === zsh-vi-mode ===
# https://github.com/jeffreytse/zsh-vi-mode
source "$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" # Init plugin

# === zsh-syntax-highlighting ===
# https://github.com/zsh-users/zsh-syntax-highlighting
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# === zsh-autosuggestions ===
# https://github.com/zsh-users/zsh-autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# === Zellij ===
alias zj="zellij"

# === 1password CLI ===
# eval "$(op completion zsh)"

# === Yandex Cloud CLI ===
# export PATH="$HOME/.yandex-cloud/bin:${PATH}" # Path to binary
# if [ -f "$HOME/.yandex-cloud/completion.zsh.inc" ]; then # Enable zsh completions
#     source "$HOME/.yandex-cloud/completion.zsh.inc"
# fi

# === STU ===
alias smlts3="stu \
    --endpoint-url https://minio.prod.lh.samoletgroup.ru:9000 \
    --profile smlt-bdd-minio \
    --bucket data \
    --region us-east-1
"
