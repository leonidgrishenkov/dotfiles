#!/bin/sh

set -euo pipefail

arch=$(uname -m)

echo "Installing mise via apt for $arch arch"

if [ "$arch" = "x86_64" ]; then
    sudo install -dm 755 /etc/apt/keyrings
    curl -s https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise
elif [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
    sudo install -dm 755 /etc/apt/keyrings
    curl -s https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=arm64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise
else
    echo "Unsupported architecture: $arch"
    exit 1
fi
