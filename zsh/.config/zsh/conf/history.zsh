# Number of commands that will be stored in history file
export HISTSIZE=1000000

# Path to history file
export HISTFILE="$ZSH_CACHE_DIR/history"
export SAVEHIST=$HISTSIZE

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

# Cycle thought history competions
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward

# Timestamp format in `history` output
HIST_STAMPS="yyyy-mm-dd"
