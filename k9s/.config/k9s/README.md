# Skins

Skins for `k9s`: <https://github.com/derailed/k9s/tree/master/skins>

# Catppuccin skins

Available here: <https://github.com/catppuccin/k9s>

Installation:

```sh
OUT="$HOME/Code/dotfiles/k9s/.config/k9s/skins" \
    && curl -Ls https://github.com/catppuccin/k9s/archive/main.tar.gz \
    | tar xz -C "$OUT" --strip-components=2 k9s-main/dist
```

Or run script:

```sh
./install.sh
```
