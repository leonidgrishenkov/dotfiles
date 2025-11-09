#!/bin/sh

set -euo pipefail

# -e: exit on error
# -u: exit on undefined variable
# -x: print each command before executing (useful for debugging)
# -o pipefail: exit if any command in a pipe fails

echo "Installing FZF"

output=$(mktemp)
target_dir=/opt/fzf
target_symlink=/usr/bin/fzf

if [ -d $target_dir ]; then
    echo "Target dir $target_dir already exists, will be reinstalled"
    rm -rf $target_dir
fi

mkdir -p "$target_dir/bin"

gh release download --repo junegunn/fzf --pattern '*linux_amd64*tar.gz' --clobber -O "$output"

tar -C "$target_dir/bin" -xzf "$output"

ln -sf "$target_dir/bin/fzf" "$target_symlink"
echo "Symlink created: $target_symlink"

rm -rf "$output"

echo "FZF has been installed"
