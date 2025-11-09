#!/bin/sh

ARCH=$(uname -m)
TARGET_DIR="/opt/nvim"

echo "Running NeoVim installer for $ARCH architecture"

if [ "$ARCH" = "x86_64" ]; then
    # TODO: add impl
    echo "64-bit Intel/AMD architecture is not implemented yet"
    exit 2
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    FILE_NAME="nvim-linux-arm64"
    TAR_FILE_NAME="$FILE_NAME.tar.gz"
  else
    echo "Unsupported architecture: $ARCH"
    exit 1
  fi

if [ -d $TARGET_DIR ]; then
    echo "Target dir $TARGET_DIR already exists, neovim will be reinstalled"
    rm -rf $TARGET_DIR
fi
mkdir -p $TARGET_DIR

curl -L https://github.com/neovim/neovim/releases/latest/download/$TAR_FILE_NAME -o /tmp/$TAR_FILE_NAME

tar -C $TARGET_DIR -xzf /tmp/$TAR_FILE_NAME

if [ -L "/usr/bin/nvim" ]; then
    unlink /usr/bin/nvim
    echo "Unlinked symlink"
fi

ln -s "$TARGET_DIR/$FILE_NAME/bin/nvim" /usr/bin/nvim
echo "Symlink created"

rm -rf /tmp/$TAR_FILE_NAME

echo "NeoVim has been installed"
