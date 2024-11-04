# Install nix

```sh
curl -L https://nixos.org/nix/install | sh
```

# Enable flake feature

Create config folder:

```sh
mkdir -p ~/.config/nix
```

Create configurations file with flakes enabled:

```sh
cat << EOF >> ~/.config/nix/nix.conf
experimental-features = nix-command flakes
build-users-group = nixbld
EOF
```

# Use flake

Add flake configuration.

Apply:

```sh
nix develop
```
