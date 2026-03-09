Install `homebrew/bundle` if it not already installed:

```sh
brew tap homebrew/bundle
```

> [!note]
> If you set `HOMEBREW_BUNDLE_FILE` env variable omit the `--file` flag.

# Dump file

Dump brewfile overwriting existing one:

```sh
brew bundle dump --force --file $DOTFILES_DIR/brew/.Brewfile
```

# Install from file

Install deps from brewfile:

```sh
brew bundle install --file $DOTFILES_DIR/brew/.Brewfile
```

# Check missing dependencies

In order to only check if any of dependencies are missing:

```sh
brew bundle check --file $DOTFILES_DIR/brew/.Brewfile
```

It will return 1 zero code if any of them are missing.

Mode detailed output:

```sh
brew bundle check --file $DOTFILES_DIR/brew/.Brewfile --verbose
```

