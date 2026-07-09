# `fish`

[Fish](https://fishshell.com/) — the friendly interactive shell.

## Setup

1. Stow the package:
   ```sh
   stow fish
   ```

2. Register fish as a valid login shell (if not already):
   ```sh
   echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
   ```

3. Set fish as the default shell:
   ```sh
   chsh -s /opt/homebrew/bin/fish
   ```

## Structure

```
.config/fish/
├── config.fish            # main entry (greeting suppression)
├── conf.d/
│   ├── 00-env.fish        # environment variables, PATH
│   ├── 01-aliases.fish    # shell aliases
│   ├── 02-vi-mode.fish    # vi keybindings (jf to escape)
│   ├── 10-starship.fish   # starship prompt
│   ├── 11-fzf.fish        # fzf fuzzy finder
│   ├── 12-atuin.fish      # atuin history
│   ├── 13-zoxide.fish     # zoxide smart cd
│   ├── 14-direnv.fish     # direnv hook
│   ├── 15-bat.fish        # bat as man pager
│   └── 50-vivid.fish      # LS_COLORS via vivid
└── functions/
    └── y.fish             # yazi CWD wrapper
```

## Features

- **Vi mode** with `jf` escape binding (matching zsh-vi-mode setup)
- **Starship** prompt (reuses existing `starship.zsh.toml`)
- **fzf** with catppuccin frappe theme and fd-based search
- **atuin** for enhanced history search
- **zoxide** for smart directory jumping
- **direnv** for per-project environment
- **bat** for colored man pages and `--help` output
- **vivid** for `LS_COLORS` with catppuccin-mocha
