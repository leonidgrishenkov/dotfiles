# Dotfiles — Agent Context

Personal dotfiles repository managed with [GNU stow](https://www.gnu.org/software/stow/) for symlinks and
[Task](https://taskfile.dev) (`taskfile.yaml`) for automation.

## Directory layout

Each top-level directory is a stow package named after the target tool. Internally it mirrors the real filesystem
structure so that stow creates correct symlinks.

Examples:

| Repo path                            | Symlinks to (real path)        |
| ------------------------------------ | ------------------------------ |
| `nvim/.config/nvim/…`                | `~/.config/nvim/…`             |
| `zsh/.config/zsh/.zshrc`             | `~/.config/zsh/.zshrc`         |
| `lazygit/.config/lazygit/config.yml` | `~/.config/lazygit/config.yml` |

When adding or editing config for a tool, place it under the matching package directory following this path convention.
Check existing directories before creating a new one from scratch.

## Neovim config

Config root: `nvim/.config/nvim/lua/`

- `lua/plugins/` is scanned by lazy.nvim as a plugin-spec directory. Put **only** `return { … }` plugin specs here —
  never shared utilities or helpers.
- `lua/utils/` holds shared modules (constants, icons, etc.) that are loaded via `require()`.
- `lua/config/` holds options, keymaps, autocmds.

## Rules

Do not run `stow` or symlink-management commands. Edit the source files directly; the user manages syncing manually.

## Git workflow

Always make changes in a separate git worktree on a new branch, so the main checkout and `main` stay untouched.

- Before the first file edit, create a new worktree on a new branch from `main`. Use the built-in worktree tool when
  one is available; otherwise run `git worktree add <path> -b <branch>`.
- Name the branch after the change in Conventional Commits style, `<type>/<short-slug>`: for example
  `feat/atuin-daemon` or `fix/nvim-heading-indent`.
- If the session is already in a worktree on a non-`main` branch for the same task, keep working there instead of
  creating another one.
- Never commit to `main` and never push to it — no `git push origin main`, no force-push, no pushing while `HEAD` is on
  `main`. Push only the task branch.
- Do not merge the branch or remove the worktree yourself. When you finish, tell the user the worktree path and the
  branch name so they can review and merge.
- Read-only tasks (answering questions, reviewing code, running read-only commands) do not need a worktree.
