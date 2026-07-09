# vim: set filetype=fish:

# https://github.com/junegunn/fzf#fuzzy-completion-for-fish

# fzf shell integration
fzf --fish | source

# Catppuccin frappe theme (transparent background)
set -gx FZF_DEFAULT_OPTS "\
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=border:#737994,label:#C6D0F5 \
--style=minimal \
--cycle \
--border=rounded"

# Preview helpers
set -l _fzf_preview_file 'bat -pp --line-range :500 --force-colorization {}'
set -l _fzf_preview_dir 'eza --tree --icons --all --color=always {} | head -200'

set -gx FZF_DEFAULT_OPTS_FILE ""

# Use fd for file finding in fzf (Ctrl+T, Ctrl+R, Alt+C)
set -gx FZF_CTRL_T_COMMAND "fd --type f -H -E .git"
set -gx FZF_CTRL_T_OPTS "--preview $_fzf_preview_file"
set -gx FZF_ALT_C_COMMAND "fd --type d -H -E .git"
set -gx FZF_ALT_C_OPTS "--preview $_fzf_preview_dir"
