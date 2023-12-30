#!/usr/bin/zsh

export CONFIGS_PATH=$HOME/code/configs

sudo apt update \
		&& sudo apt install -y zsh lf ripgrep wget bat exa neovim \
		&& chsh -s zsh


sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k \
		&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting \
		&& git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

ln -sfiv $CONFIGS_PATH/zsh/deb/.zshrc $HOME/.zshrc \
		&& mkdir -pv $ZSH_CUSTOM/plugins/vi-mode && ln -sfiv $CONFIGS_PATH/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh $ZSH_CUSTOM/plugins/vi-mode/vi-mode.plugin.zsh \
		&& mkdir -pv $HOME/.config/lf && ln -sfiv $CONFIGS_PATH/lf/lfrc $HOME/.config/lf/lfrc \
		&& mkdir -pv $HOME/.config/nvim && for file in $CONFIGS_PATH/nvim/*; do ln -sfiv $file $HOME/.config/nvim/$(basename $file); done

