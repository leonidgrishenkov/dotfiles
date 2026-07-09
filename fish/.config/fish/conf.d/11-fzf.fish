# vim: set filetype=fish:

# https://github.com/junegunn/fzf
#
# Fish differs from bash/zsh:
# - Tab    = native fish completion (preserved)
# - Shift+Tab = fuzzy completion (replaces native pager search)
# - Ctrl+T = fuzzy file search (uses last token as root dir)
# - Ctrl+R = history search
# - Alt+C  = cd into directory

# Shell integration
fzf --fish | source

# Shift+Tab: fuzzy completion with file/dir preview
set -gx FZF_COMPLETION_OPTS "--preview '_fzf_preview {}'"

# Catppuccin frappe theme (transparent background)
set -gx FZF_DEFAULT_OPTS "\
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=border:#737994,label:#C6D0F5 \
--style=minimal \
--cycle \
--border=rounded"

# Ctrl+T: search files under last token as root dir
set -gx FZF_CTRL_T_COMMAND "fd --type f -H -E .git \$dir"
set -gx FZF_CTRL_T_OPTS "--preview '_fzf_preview {}'"

# Alt+C: cd into directory
set -gx FZF_ALT_C_COMMAND "fd --type d -H -E .git \$dir"
set -gx FZF_ALT_C_OPTS "--preview '_fzf_preview {}'"
