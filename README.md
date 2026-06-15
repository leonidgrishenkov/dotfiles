# Dotfiles

Personal dotfiles repository managed with [GNU stow](https://www.gnu.org/software/stow/).

Each top-level directory is a stow package named after the target tool (e.g. `lazygit/`, `zsh/`, `nvim/`).
Internally, these directories mirror the real filesystem structure so that stow creates correct symlinks.
For example, `lazygit/.config/lazygit/config.yml` maps to `~/.config/lazygit/config.yml`.

## Prerequisites

Install GNU stow:

```sh
brew install stow
```

## Symlinking packages

To sync a package to your machine, run:

```sh
stow lazygit
```

This creates symlinks in your home directory (configured via `.stowrc`) matching the internal directory structure of the package.

Multiple packages can be specified at once:

```sh
stow lazygit zsh zellij
```

### Other useful commands

**Dry run** — preview what would change without making any changes:

```sh
stow -n lazygit
```

**Restow** — recreate symlinks (useful after renaming or restructuring directories):

```sh
stow --restow lazygit
```

**Delete** — remove symlinks for a package:

```sh
stow --delete lazygit
```

Additional default options are set in the `.stowrc` file.
