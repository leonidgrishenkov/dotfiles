This repository is addapted to work with [GNU stow](https://www.gnu.org/software/stow/).

To start syncing local machine configuration with this repo, for example, for `lazygit` execute this command:

```shell
stow --target=$HOME \
    --stow lazygit \
    --verbose
```

This command will create a symlinks with files structure correcponding to specified app name in this repo, in this example `lazygit`.
