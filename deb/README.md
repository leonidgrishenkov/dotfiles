


# lf

```shell
sudo apt install lf -y
```

```shell
mkdir -p ~/.config/lf \
&& ln -s ~/code/configs/macos/lf/lfrc ~/.config/lf/lfrc
```

# ripgrep

```shell
sudo apt install ripgrep -y
```

# oh-my-zsh

```shell
ln -s -f ~/code/configs/macos/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh ~/.oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh
```


```shell
sudo apt update && sudo apt install -y zsh lf ripgrep wget \
&& chsh -s zsh

```

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&& git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```



```shell
ln -sfiv ~/.zshrc ~/code/configs/macos/zsh/.zshrc \
ln -sfiv ~/code/configs/macos/oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh ~/.oh-my-zsh/plugins/vi-mode/vi-mode.plugin.zsh \
&& mkdir -p ~/.config/lf && ln -sfiv ~/code/configs/macos/lf/lfrc ~/.config/lf/lfrc \
&& mkdir -p ~/.config/nvim && for file in ~/code/configs/macos/nvim/*; echo $file; done
```
