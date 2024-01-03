export CONFIGS_PATH=$HOME/code/configs


# Get Meslo Nerd Fonts
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo
mkdir -pv $HOME/Library/Fonts/meslo-nerd-fonts \
		&& wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.tar.xz -O $HOME/Library/Fonts/meslo-nerd-fonts/Meslo.tar.xz \
		&& tar -xvf $HOME/Library/Fonts/meslo-nerd-fonts/Meslo.tar.xz \
		&& rm $HOME/Library/Fonts/meslo-nerd-fonts/Meslo.tar.xz

mkdir -pv /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode && ln -sfiv /Users/leonidgrisenkov/code/configs/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode/vi-mode.plugin.zsh


mkdir -pv $HOME/.config/lf \
		&& ln -sfiv $CONFIGS_PATH/lf/lfrc $HOME/.config/lf/lfrc \
		&& ln -sfiv $CONFIGS_PATH/lf/icons $HOME/.config/lf/icons

for file in /Users/leonidgrisenkov/code/configs/nvim/*; do ln -sfiv /Users/leonidgrisenkov/code/configs/nvim/init.vim /Users/leonidgrisenkov/.config/nvim/init.vim; done

ln -sfiv /Users/leonidgrisenkov/code/configs/ssh/config /Users/leonidgrisenkov/.ssh/config

ln -sfiv /Users/leonidgrisenkov/code/configs//hyper/.hyper.js  /Users/leonidgrisenkov/.hyper.js


# Neovim configurations
mkdir -pv $HOME/.config/nvim/lua/core 

