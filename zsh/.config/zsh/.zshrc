#!/bin/zsh
# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

export SYSTEM="$(uname -s)"

[[ ! -z $EDITOR ]] || export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'

# ========= homebrew =========
if command -v /opt/homebrew/bin/brew &>/dev/null; then
    # Export all `brew` env vars. See `man brew` + `/shellenv`
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # No emoji in download output
    # export HOMEBREW_NO_EMOJI=1
    export HOMEBREW_INSTALL_BADGE=""

    # Don't show hints for env vatialbes
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"

    # Add to FPATH completions installed by brew
    FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
fi

# Set one of the editor as $EDITOR
EDITORS="nvim,vim,vi"
for editor in $(echo $EDITORS | sed "s/,/ /g"); do
    if command -v $editor &>/dev/null; then
        export EDITOR=$editor
        break
    fi
done
# Send message if no one editor is installed
[[ ! -z $EDITOR ]] || echo "No editor is installed" >&2

export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export PAGER="less"
# Use nvim as man pager:
# export MANPAGER="nvim +Man!"
alias v=$EDITOR

# Enable `cargo`
if [[ -d "$HOME/.cargo" ]]; then source "$HOME/.cargo/env"; fi

# If we are on linux machine add alias for batcat
# to be consistent with usage on  macos.
# if [[ $SYSTEM = "Linux" ]]; then alias bat="batcat"; fi

if command -v bat &>/dev/null; then
    # https://github.com/sharkdp/bat

    # Set zsh-syntax-highlighting theme
    export BAT_THEME="catppuccin-frappe"
    # Setup output elements to show
    export BAT_STYLE="header,numbers,grid"
    export BAT_PAGING="always"
    export BAT_PAGER="less -RF"

    # Use bat to show man pages output.
    # https://github.com/sharkdp/bat#man
    export MANPAGER="sh -c 'col -bx | bat --language=man --style=plain'"

    # Use bat to show help pages output.
    # https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi

if command -v rg &>/dev/null; then
    alias gr="rg --color=always"
fi

if command -v eza &>/dev/null; then
    alias ls="eza --all --oneline --icons --group-directories-first"
    alias ll="eza --all --long --icons --group-directories-first --created --modified --header --binary --time-style long-iso"
    alias tree="eza --tree --all --icons --group-directories-first --ignore-glob='.git*|.venv*|__pycache__*|.DS_store'"
fi

# https://github.com/noahgorstein/jqp?tab=readme-ov-file#configuration
if command -v jqp &>/dev/null; then
    alias jqp="jqp --theme catppuccin-frappe"
fi

# ========= zinit =========
#
# Repo: https://github.com/zdharma-continuum/zinit
#
# Install zinit if it doesn't installed and create its directory
ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Activate zinit
source "${ZINIT_HOME}/zinit.zsh"

# Path to zsh cache
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"

# If it doesn't exists create one
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR

# Path to completions cache
# BUG: This doesn't work, cache stores in ~/.config/zsh/ directory
ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"

# Install zsh plugins via zinit
#
# https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting

# https://github.com/zsh-users/zsh-completions
zinit light zsh-users/zsh-completions

# https://github.com/zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions

# https://github.com/Aloxaf/fzf-tab
zinit light Aloxaf/fzf-tab

# Install plugins from oh-my-zsh repo.
#
# Enable vim mode support in CLI
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vi-mode
zinit snippet OMZP::vi-mode

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# ========= Autocompletion options =========
#
# Display dots (or given format) when waiting for completions
COMPLETION_WAITING_DOTS="%F{grey}waiting...%f"

# COMPLETION_WAITING_DOTS="true"
# Use case-sensitive autocompletion
CASE_SENSITIVE=true

# Auto set terminal tab title
DISABLE_AUTO_TITLE=false

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE=false

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY=true

# Add colors for cd into directory competions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completions should be case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# ========= History settings =========
#
# Number of commands that will be stored in history file
HISTSIZE=2000

# Path to history file
HISTFILE="$ZSH_CACHE_DIR/history"

SAVEHIST=$HISTSIZE

# Erase duplicates in history file
HISTDUP=erase

# History options for zsh
# Appned commands into history file instead of overwrite them
setopt appendhistory

# Share history across all zsh sessions
setopt sharehistory

# Don't write to history commands with space before it.
# This is usefull to prevent any sensetive command to be written into history file.
setopt hist_ignore_space

# All 3 commands below will prevent zsh to save and store duplicates in history file.
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Don't show duplicates into prompt when cycle thought them.
setopt hist_find_no_dups

# Don't let > silently overwrite files. To overwrite, use >! instead.
setopt no_clobber

# Use modern file-locking mechanisms, for better safety & performance.
setopt hist_fcntl_lock

alias h="history | tail -n 50"

# Cycle thought history competions
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"

# ========= starship =========
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
    # Set var with path to config file
    export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
fi

# ========= yazi =========
# Use `yy` as shell command wrapper that provides the ability
# to change the current working directory when exiting Yazi.
# Took from utility doc: https://yazi-rs.github.io/docs/quick-start#shell-wrapper
if command -v yazi &>/dev/null; then
    function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# ========= zoxide =========
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# ========= fzf =========
# https://github.com/junegunn/fzf
if command -v fzf &>/dev/null; then
    # Set up fzf key bindings and fuzzy completion
    # https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
    source <(fzf --zsh)

    # https://github.com/junegunn/fzf#layout
    # export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=sharp --margin=0,1,0,1%"

    # Options to fzf command
    # export FZF_COMPLETION_OPTS='--border --info=inline'

    # Catppuccin frappe theme.
    # https://github.com/catppuccin/fzf
    export FZF_DEFAULT_OPTS=" \
        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
        --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
        --color=selected-bg:#51576d \
        --multi"

    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
    }

    show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

    function _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
            export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
    }
fi

# ========= zsh plugins configuration =========
# zsh-autosuggestions:
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
# Set bindkey to accept currently shown autosuggestion
bindkey '^k' autosuggest-accept

# ========= Vim mode =========
export KEYTIMEOUT=15
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
# Cursor style
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=1
VI_MODE_CURSOR_VISUAL=2
VI_MODE_CURSOR_INSERT=5
VI_MODE_CURSOR_OPPEND=0
# Keymappings
# Enter cmd mode from insert mode
bindkey -M viins jf vi-cmd-mode
# Movements
bindkey -M vicmd h vi-backward-char
bindkey -M visual h vi-backward-char
bindkey -M vicmd j vi-down-line-or-history
bindkey -M vicmd k vi-up-line-or-history
bindkey -M vicmd l vi-forward-char
bindkey -M vicmd ee edit-command-line

if [[ $SYSTEM = "Darwin" ]]; then
    # Yank to the system clipboard
    function vi-yank-xclip {
        zle vi-yank
    echo "$CUTBUFFER" | pbcopy -i
    }
    zle -N vi-yank-xclip
    bindkey -M vicmd 'y' vi-yank-xclip
fi

# Alias for lazygit
if command -v lazygit &>/dev/null; then alias g="lazygit"; fi

update_zellij_pane_name() {
    # https://www.reddit.com/r/zellij/comments/10skez0/does_zellij_support_changing_tabs_name_according/?rdt=58606
    # If we are inside zellij
    if [[ -n $ZELLIJ ]]; then
        local _current_dir=$PWD

        if [[ $_current_dir == $HOME ]]; then
            local _pane_name="~"
        else
            # TODO: add less short substitution
            # _pane_name="../${_current_dir##*/}"
            local _pane_name=$_current_dir
        fi

        # TODO: this doesn't work
        if [[ -n $SSH_CONNECTION ]]; then
            _pane_name="ssh-test"
        fi

        command nohup zellij action rename-pane $_pane_name >/dev/null 2>&1
    fi
}

# zellij multiplexor
if command -v zellij &>/dev/null; then
    alias zj="zellij"

    # Add hook to invoke func to update zellij pane name.
    # autoload -U add-zsh-hook
    # add-zsh-hook chpwd update_zellij_pane_name
fi

# ========= kubectl =========
if command -v kubectl &>/dev/null; then
  alias k="kubectl"
fi

alias rm="rm -Iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias c="clear"


# ========= macos only =========
if [[ $SYSTEM = "Darwin" ]]; then
    # Yandex Cloud CLI - `yc`.
    # Add binary to PATH.
    if [ -d "$HOME/.yandex-cloud/bin" ]; then
        export PATH="$HOME/.yandex-cloud/bin:${PATH}"

        # Enable zsh completions.
        if [ -f "$HOME/.yandex-cloud/completion.zsh.inc" ]; then
            source "$HOME/.yandex-cloud/completion.zsh.inc"
        fi

        # Add aliases for some common commands.
        alias yccil="yc compute instance list"
    fi
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

if command -v terraform &>/dev/null; then
    alias t="terraform"
fi

if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# 1password-cli
if command -v op &>/dev/null; then
    eval "$(op completion zsh)"
fi

if command -v stu &>/dev/null; then
    alias smlts3="stu \
        --endpoint-url https://minio.prod.lh.samoletgroup.ru:9000 \
        --profile smlt-bdd-minio \
        --bucket data \
        --region us-east-1
    "
fi

# Setting over ssh session
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi
