#!/usr/bin/env zsh

set -e

CONFIG_FOLDERS="hyper,zsh,nvim,lf,oh-my-zsh"
ROOT_PATH="$HOME/Code/configs"

cd $ROOT_PATH

echo "Process $CONFIG_FOLDERS folders from $ROOT_PATH"

for folder in $(echo $CONFIG_FOLDERS | sed "s/,/ /g"); do

    stow -t $HOME -D $folder -v --ignore=README.md --ignore=LICENSE 

    stow -t $HOME -S $folder -v

    echo "[+] $folder"
done
