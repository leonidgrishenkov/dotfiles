
Execute `p10k configure` with diferent path:

```shell
POWERLEVEL9K_CONFIG_FILE=/path/to/file p10k configure
```

Symlink to this will stay untouched after overwriting config:

```shell
POWERLEVEL9K_CONFIG_FILE="$HOME/Code/configs/p10k/.config/p10k/.p10k.zsh" p10k configure
```

