This repository is addapted to work with [GNU stow](https://www.gnu.org/software/stow/).

To start syncing local machine configuration with this repo, for example, for `lazygit` execute this command:

```sh
stow --target=$HOME \
    --stow lazygit \
    --verbose
```

This command will create a symlinks with files structure corresponding to specified app name in this repo, in this example `lazygit`.


Several items can be listed with a space like that:

```sh
stow --target=$HOME \
    --stow lazygit zsh zellij \
    --verbose
```

# Recreate symlinks

To recreate symlinks, for example there were made some changes in directories names:

```sh
stow --target=$HOME \
    --restow lazygit \
    --verbose
```

# Delete symlinks

To delete symlinks:

```sh
stow --target=$HOME \
    --delete lazygit \
    --verbose
```

# Clone repository

To clone this repository localy:

```sh
git clone git@github-personal:leonidgrishenkov/dotfiles.git
```

Where `github-personal` is the name of corresponding ssh key configuration in `~/.ssh/config`.
