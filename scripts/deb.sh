export CONFIGS_PATH=$HOME/code/configs

export ZSH_CUSTOM=

# Upgrade apt and install main utilities
sudo apt update \
    && sudo apt upgrade -y \
    && sudo apt install -y zsh lf git ripgrep wget curl bat exa stow fzf jq

# Change default shell for $USER
chsh -s $(which zsh)

# Install oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install oh-my-zsh plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k \
		&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting \
		&& git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# 
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# git-ignore
# https://github.com/laggardkernel/git-ignore
git clone https://github.com/laggardkernel/git-ignore.git $ZSH_CUSTOM/plugins/git-ignore

# zsh-help
# https://github.com/Freed-Wu/zsh-help
git clone https://github.com/Freed-Wu/zsh-help.git $ZSH_CUSTOM/plugins/zsh-help

# fast-syntax-highlighting
# https://github.com/zdharma-continuum/fast-syntax-highlighting
git clone -q https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting

git clone https://github.com/trystan2k/zsh-tab-title $ZSH_CUSTOM/plugins/zsh-tab-title


# Install poetry 
# https://python-poetry.org/docs/#installing-with-the-official-installer
sudo curl -sSL https://install.python-poetry.org \
    | sudo POETRY_HOME=/opt/poetry python3 -
sudo ln -sf /opt/poetry/bin/poetry /usr/local/bin/poetry



