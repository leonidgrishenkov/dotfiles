# `zsh`

[Zsh](https://www.zsh.org/) — the Z shell.

## Structure

```
zsh/
├── .zshenv                        # XDG dirs, ZDOTDIR, bootstraps .zprofile
└── .config/zsh/
    ├── .zprofile                  # locale settings
    ├── .zshrc                     # thin loader — globs conf.d/ and extra/
    ├── conf.d/
    │   ├── 00-env.zsh             # EDITOR, PATH, LS_COLORS, env vars
    │   ├── 01-history.zsh         # history size, dedup, options
    │   ├── 02-completion.zsh      # FPATH, zstyles, keybindings
    │   ├── 03-aliases.zsh         # shell aliases
    │   ├── 04-plugins.zsh         # zsh-vi-mode, autosuggestions, syntax highlighting
    │   ├── 05-compinit.zsh        # compinit (must run after plugins source)
    │   ├── 10-starship.zsh        # starship prompt init
    │   ├── 11-fzf.zsh             # fzf + catppuccin frappe theme
    │   ├── 12-atuin.zsh           # atuin history init
    │   ├── 13-zoxide.zsh          # zoxide init
    │   ├── 14-direnv.zsh          # direnv hook
    │   ├── 15-bat.zsh             # bat as man/help pager
    │   ├── 16-yazi.zsh            # yazi CWD wrapper
    │   ├── 20-linux.zsh           # linux-specific (mise)
    │   ├── 21-macos.zsh           # brew, gpg, 1password, orbstack, etc.
    │   └── 99-keyfixes.zsh        # zvm_after_init hook (atuin keybinds)
    └── extra/
        └── .gitkeep               # user/machine-specific overrides
```

## Load order

Files in `conf.d/` are sourced in natural sort order (`*.zsh` glob).
Numeric prefixes control dependency ordering:

| Range | Purpose |
|---|---|
| `00–05` | Core shell: env, history, completion, aliases, plugins, compinit |
| `10–19` | Tool integrations: starship, fzf, atuin, zoxide, direnv, bat, yazi |
| `20–29` | Platform-specific: linux, macos |
| `99` | Late keybinding fixes that must run after all plugins are loaded |

## Performance

To check zsh startup time:

```sh
for i in $(seq 1 10); do time zsh -i -c exit; done
```
