# vim: set filetype=fish:

# === Shortcuts (expand inline via abbr) ===
abbr --add k kubectl
abbr --add v $VISUAL
abbr --add l lazygit
abbr --add tf terraform
abbr --add tg terragrunt

# === Claude ===
abbr --add c claude
abbr --add ch claude --model haiku
abbr --add cs claude --model sonnet
abbr --add cf claude --model fable

# === Git ===
abbr --add g git
abbr --add gs git status
abbr --add ga git add --all
abbr --add gc git commit
abbr --add gp git push

# === Docker ===
abbr --add d docker
abbr --add dd docker exec -it -e TERM_PROGRAM=ghostty devcr fish

# Include hidden/ignore files by default
abbr --add rg "rg -."
abbr --add fd "fd -IH"

# === Eza ===
alias ls="eza --icons=auto --group-directories-first --time-style=long-iso"
