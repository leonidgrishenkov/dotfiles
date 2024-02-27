export CONFIGS_PATH=$HOME/code/configs



mkdir -pv /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode && ln -sfiv /Users/leonidgrisenkov/code/configs/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode/vi-mode.plugin.zsh


mkdir -pv $HOME/.config/lf \
		&& ln -sfiv $CONFIGS_PATH/lf/lfrc $HOME/.config/lf/lfrc \
		&& ln -sfiv $CONFIGS_PATH/lf/icons $HOME/.config/lf/icons

for file in /Users/leonidgrisenkov/code/configs/nvim/*; do ln -sfiv /Users/leonidgrisenkov/code/configs/nvim/init.vim /Users/leonidgrisenkov/.config/nvim/init.vim; done

ln -sfiv /Users/leonidgrisenkov/code/configs/ssh/config /Users/leonidgrisenkov/.ssh/config

ln -sfiv /Users/leonidgrisenkov/code/configs//hyper/.hyper.js  /Users/leonidgrisenkov/.hyper.js


# Neovim configurations
mkdir -pv $HOME/.config/nvim/lua/core 

