export CONFIGS_PATH=/Users/leonidgrisenkov/code/configs
mkdir -pv /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode && ln -sfiv /Users/leonidgrisenkov/code/configs/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh /Users/leonidgrisenkov/.oh-my-zsh/custom/plugins/vi-mode/vi-mode.plugin.zsh
ln -sfiv /Users/leonidgrisenkov/code/configs/lf/lfrc /Users/leonidgrisenkov/.config/lf/lfrc
for file in /Users/leonidgrisenkov/code/configs/nvim/*; do ln -sfiv /Users/leonidgrisenkov/code/configs/nvim/init.vim /Users/leonidgrisenkov/.config/nvim/init.vim; done
ln -sfiv /Users/leonidgrisenkov/code/configs/ssh/config /Users/leonidgrisenkov/.ssh/config
ln -sfiv /Users/leonidgrisenkov/code/configs//hyper/.hyper.js  /Users/leonidgrisenkov/.hyper.js
