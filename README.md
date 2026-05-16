# Dotfiles

## Create symlinks with `stow`

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

To recreate symlinks, for example there were made some changes in directories names:

```sh
stow --restow lazygit
```

To delete symlinks:

```sh
stow --delete lazygit
```

## Submodules

### Clone

There are a few git submodules in `./external` directory, dedicated for that.

To clone on a fresh machine:

```sh
git clone --recurse-submodules URL
```

To update on existing one:

```sh
git submodule update --init --recursive
```

### Add a new one

To add new submodule:

```sh
git submodule add URL ./external/SUBMODULE_NAME
```
