# vim: set filetype=sh:
# vim: set ts=4 sw=4 et:

# === fzf ===
# https://github.com/junegunn/fzf
# https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
source <(fzf --zsh)

# Catppuccin frappe theme (transparent background).
# Source: https://github.com/catppuccin/fzf
export FZF_DEFAULT_OPTS=" \
    --color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
    --color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
    --color=border:#737994,label:#C6D0F5 \
    --style=minimal \
    --cycle \
    --border=rounded"

_show_file_preview="bat -pp --line-range :500 --force-colorization {}"
_show_dir_preview="eza --tree --icons --all --color=always {} | head -200"
_show_file_or_dir_preview="if [ -d {} ]; then $_show_dir_preview; else $_show_file_preview; fi"

function _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    vim | nvim | v | code | open) fzf --preview "$_show_file_or_dir_preview" "$@" ;;
    ls | eza | cd) fd --type d -H -E .git | fzf --preview "$_show_dir_preview" "$@" ;;
    cat | bat) fd --type f -H -E .git | fzf --preview "$_show_file_preview" "$@" ;;
    export | unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh | telnet) fzf --preview 'dig {}' "$@" ;;
    kill | pkill) fzf --preview 'ps -f -p {}' --preview-window=down:3:wrap "$@" ;;
    *) fzf "$@" ;;
    esac
}
