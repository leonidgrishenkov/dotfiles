#!/bin/sh

set -euo pipefail

output=$(mktemp)
target_dir=/opt/ripgrep
target_symlink=/usr/bin/rg

if [ -d $target_dir ]; then
    echo "Target dir $target_dir already exists, reinstalling"
    rm -rf $target_dir
fi

mkdir -p $target_dir

gh release download --repo BurntSushi/ripgrep --pattern '*aarch64*linux*tar.gz' --clobber -O "$output"

tar -C "/opt/ripgrep" --strip-components=1 -xzf "$output"

ln -sf "$target_dir/rg" $target_symlink
echo "Symlink created: $target_symlink"

rm -rf "$output"

echo "Ripgrep has been installed"
