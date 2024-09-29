This repository is addapted to work with [GNU stow](https://www.gnu.org/software/stow/).

To start syncing local machine configuration with this repo, for example, for `lazygit` execute this command:

```shell
stow --target=$HOME \
    --stow lazygit \
    --verbose
```

This command will create a symlinks with files structure correcponding to specified app name in this repo, in this example `lazygit`.

To recreate symlinks, for example there were made some changes in directories names:

```shell
stow --target=$HOME \
    --restow lazygit \
    --verbose
```

To delete symlinks:

```shell
stow --target=$HOME \
    --delete lazygit \
    --verbose
```

A few items could be listed with a comma:

```shell
stow --target=$HOME \
    --restow lazygit,zsh,zellij \
    --verbose
```
