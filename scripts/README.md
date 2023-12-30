
# MacOS

zsh:

```shell
ln -s ~/Code/configs/macos/zsh/.zshrc  ~/.zshrc
```


hyper:

```shell
ln -s ~/Code/configs/macos/hyper/.hyper.js  ~/.hyper.js      
```

lf:

```shell
ln -s ~/Code/configs/macos/lf/lfrc ~/.config/lf/lfrc
```

neovim:

```shell
ln -s ~/Code/configs/macos/nvim/init.vim ~/.config/nvim/init.vim \
&& ln -s ~/Code/configs/macos/nvim/config.vim ~/.config/nvim/config.vim
```

oh-my-zsh plugins vi-mode:

```shell
ln -s ~/Code/configs/macos/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh ~/.oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh
```

ssh:

```shell
ln -s ~/Code/configs/macos/ssh/config ~/.ssh/config
```


# Debian

```shell
sudo apt update && sudo apt install -y zsh lf ripgrep wget bat exa neovim \
&& chsh -s zsh

```

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&& git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k \
&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting \
&& git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```



```shell
export CONFIGS_PATH=$HOME/code/configs

ln -sfiv $CONFIGS_PATH/zsh/deb/.zshrc $HOME/.zshrc \

&& mkdir -pv $ZSH_CUSTOM/plugins/vi-mode && ln -sfiv $CONFIGS_PATH/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh $ZSH_CUSTOM/plugins/vi-mode/vi-mode.plugin.zsh \

&& mkdir -pv $HOME/.config/lf && ln -sfiv $CONFIGS_PATH/lf/lfrc $HOME/.config/lf/lfrc \

&& mkdir -pv $HOME/.config/nvim && for file in $CONFIGS_PATH/nvim/*; do ln -sfiv $file $HOME/.config/nvim/$(basename $file); done

```
