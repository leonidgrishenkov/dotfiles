
Install list of packages:
```shell
sudo apt update \
    && sudo apt upgrade -y
    && sudo xargs -a $(pwd)/apt.list apt install -y
```
