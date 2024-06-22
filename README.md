
This repository is addapted to work with [GNU stow](https://www.gnu.org/software/stow/) utility.

To start syncing you local app or utility configuration with this repo execute this command:

```shell
stow -v -t $HOME -S lazygit
```

This command will create a symlinks with file structure correcponding to specifies app path in this repo.

