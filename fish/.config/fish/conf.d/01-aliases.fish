# vim: set filetype=fish:

# === Shortcuts (expand inline via abbr) ===
abbr --add k kubectl
abbr --add d docker
abbr --add dv docker exec -it -e TERM_PROGRAM=ghostty devcr fish
abbr --add t terragrunt
abbr --add g git
abbr --add v $VISUAL
abbr --add gp gopass
abbr --add l lazygit
abbr --add c claude
abbr --add ch claude --model haiku
abbr --add cs claude --model sonnet
abbr --add cf claude --model fable

# Include hidden/ignore files by default
abbr --add rg "rg -."
abbr --add fd "fd -IH"

# === Eza ===
alias ls="eza --icons=auto --group-directories-first --time-style=long-iso"
