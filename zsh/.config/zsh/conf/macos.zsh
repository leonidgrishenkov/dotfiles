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

# 'zsh-syntax-highlighting' quite old plugin but loads much faster then 'fast-syntax-highlighting'.
# Repo: https://github.com/zsh-users/zsh-syntax-highlighting
# source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# === Additional ZSH completions ===
# Repo: https://github.com/zsh-users/zsh-completions
export FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"

# === Plugin that reminds to use aliases ===
source "$HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh"

# === Zellij ===
alias zj="zellij"

# Helper function to send the title update to Zellij
function change_pane_title() {
  local title=$1
  command nohup zellij action rename-pane $title >/dev/null 2>&1
}

function set_pane_to_command_line() {
  local cmdline=$1
  local max_length=20

  if [[ ${#cmdline} -gt $max_length ]]; then
    # Slice from character 1 to max_length and add ".." at the end
    local truncated_title="${cmdline[1,$max_length]} .."
    change_pane_title $truncated_title
  else
    change_pane_title $cmdline
  fi
}

function clear_title_on_failure() {
  # Save the exit code of the last command immediately
  local last_status=$?

  if [[ -n $ZELLIJ ]]; then
    if [[ $last_status -ne 0 ]]; then
      # Command failed: Clear the title (resets to default Zellij name)
      command nohup zellij action undo-rename-pane >/dev/null 2>&1
    # else
    #   # Optional: Set the title to the current directory name on success
    #   local dir_name=$(basename "$PWD")
    #   command nohup zellij action rename-pane "$dir_name" >/dev/null 2>&1
    fi
  fi
}

if [[ -n $ZELLIJ ]]; then
  # Use the preexec hook to get the command line before it runs
  add-zsh-hook preexec set_pane_to_command_line
  # autoload -Uz add-zsh-hook
  add-zsh-hook precmd clear_title_on_failure
fi

# === zoxide ===
eval "$(zoxide init zsh)"

# === Golang ===
export GOPATH=$HOME/.go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

# === direnv ===
eval "$(direnv hook zsh)"

# === jqp ===
# https://github.com/noahgorstein/jqp?tab=readme-ov-file#configuration
alias jqp="jqp --theme catppuccin-frappe"

# === 1password CLI ===
# eval "$(op completion zsh)"

# === DataGrip ===
# Run DataGrip from the shell.
# https://www.jetbrains.com/help/datagrip/working-with-the-ide-features-from-command-line.html#standalone
function datagrip() {
    open -a "DataGrip.app" --args "$@"
}

# This helps to find docker related executables installed by docker desktop.
export "PATH=/Applications/Docker.app/Contents/Resources/bin:$PATH"

alias yccl="yc compute instance list"

# YC completions are quite expensive to load on each ZSH startup, so I prefer to load it manually when it's necessary.
function enable-yc() {
    echo -e "${SUCCESS}Loading yc completions"

    cask_name="yandex-cloud-cli"
    yc_installed_version=$(brew info --cask $cask_name --json=v2 | jq -r '.casks[0].version')

    comp_source_file="$HOMEBREW_PREFIX/Caskroom/$cask_name/${yc_installed_version}/$cask_name/completion.zsh.inc"

    echo -e "${SUCCESS}Using file: $comp_source_file"
    source $comp_source_file
}
