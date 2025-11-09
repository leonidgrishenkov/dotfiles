#!/bin/sh

set -euo pipefail

echo "Installing github CLI"

output=$(mktemp)

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -o "$output" https://cli.github.com/packages/githubcli-archive-keyring.gpg
cat "$output" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

echo "GitHub CLI installed"
