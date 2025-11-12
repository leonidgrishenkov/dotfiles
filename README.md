This repository is adapted to work with [GNU stow](https://www.gnu.org/software/stow/).

To start syncing local machine configuration with this repo, for example, for `lazygit` execute this command:

```sh
stow lazygit
```

This command will create a symlinks with files structure corresponding to specified app name in this repo, in this example `lazygit`.

Additional configuration options can be found in `.stowrc` file.

Several items can be listed separated by space like that:

```sh
stow lazygit zsh zellij
```

# Recreate symlinks

To recreate symlinks, for example there were made some changes in directories names:

```sh
stow --restow lazygit
```

# Delete symlinks

To delete symlinks:

```sh
stow --delete lazygit
```
