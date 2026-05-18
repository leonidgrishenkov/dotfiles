# Plugins

## zjstatus

[GitHub](https://github.com/dj95/zjstatus)

Download binary:

```sh
ZJSTATUS_VERSION="v0.21.1"

wget -q --show-progress -O \
    "$DOTFILES_DIR/zellij/.config/zellij/plugins/zjframes.wasm" \
    "https://github.com/dj95/zjstatus/releases/download/$ZJSTATUS_VERSION/zjframes.wasm"

wget -q --show-progress -O \
    "$DOTFILES_DIR/zellij/.config/zellij/plugins/zjstatus.wasm" \
    "https://github.com/dj95/zjstatus/releases/download/$ZJSTATUS_VERSION/zjstatus.wasm"
```

Make sure `DOTFILES_DIR` environment variable is set.
