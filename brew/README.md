Install `homebrew/bundle` if not already installed:

```sh
brew tap homebrew/bundle
```

Dump brewfile overwriting existing one:

```sh
brew bundle dump --force --file $HOME/Code/dotfiles/brew/.Brewfile
```

Install deps from brewfile:

```sh
brew bundle install --file $HOME/Code/dotfiles/brew/.Brewfile
```
