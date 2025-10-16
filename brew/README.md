Install `homebrew/bundle` if it not already installed:

```sh
brew tap homebrew/bundle
```

Dump brewfile overwriting existing one:

```sh
brew bundle dump --force --file $DOTFILES_DIR/brew/.Brewfile
```

Install deps from brewfile:

```sh
brew bundle install --file $DOTFILES_DIR/brew/.Brewfile
```
