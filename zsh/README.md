
# Performance

In order to check current zsh startup time execute this:

```sh
for i in $(seq 1 10); do time zsh -i -c exit; done;
```
