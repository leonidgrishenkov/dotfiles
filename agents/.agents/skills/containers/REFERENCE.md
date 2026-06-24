# Container CLI Reference

## container run

Run a container from an image.

```bash
container run [options] <image> [args...]
```

| Flag                                        | Description                               |
| ------------------------------------------- | ----------------------------------------- |
| `-d, --detach`                              | Run in background                         |
| `--name <name>`                             | Assign a name (also used as container ID) |
| `-e, --env <key=val>`                       | Set environment variable                  |
| `--env-file <path>`                         | Load env vars from file                   |
| `-p <host>:<container>`                     | Publish a port                            |
| `-v <host>:<container>`                     | Bind mount (shortcut)                     |
| `--mount type=bind,source=...,target=...`   | Bind mount (explicit)                     |
| `--mount type=volume,source=...,target=...` | Volume mount                              |
| `--network <name>`                          | Attach to a network                       |
| `-w, --workdir <dir>`                       | Set working directory                     |
| `--entrypoint <cmd>`                        | Override entrypoint                       |
| `-i, --interactive`                         | Keep stdin open                           |
| `-t, --tty`                                 | Allocate a TTY                            |
| `--init`                                    | Run init as PID 1                         |
| `-c, --cpus <n>`                            | CPU limit                                 |
| `-m, --memory <size>`                       | Memory limit (e.g. `512M`, `1G`)          |
| `--dns <ip>`                                | Custom DNS server                         |
| `-l, --label <key=val>`                     | Add a label                               |
| `--rm`                                      | Remove container when it exits            |
| `-a, --arch <arch>`                         | Target architecture (default: `arm64`)    |

### Examples

```bash
# Interactive shell
container run -it --rm alpine sh

# Background web server with port mapping
container run -d --name web -p 8080:80 nginx

# With env vars and volume
container run -d --name app \
  -e DATABASE_URL=postgres://localhost/db \
  --mount type=volume,source=appdata,target=/data \
  myapp:latest

# With resource limits
container run -d -c 2 -m 1G --name worker myapp:latest
```

## container build

Build an image from a Dockerfile.

```bash
container build [options] [context-dir]
```

| Flag                    | Description               |
| ----------------------- | ------------------------- |
| `-t, --tag <name>`      | Tag the image             |
| `-f, --file <path>`     | Path to Dockerfile        |
| `--build-arg <key=val>` | Set build-time variable   |
| `--target <stage>`      | Target build stage        |
| `--no-cache`            | Disable layer cache       |
| `--platform <os/arch>`  | Target platform           |
| `--secret <id=key,...>` | Build-time secret         |
| `-q, --quiet`           | Suppress output           |
| `--pull`                | Always pull base images   |
| `--progress <type>`     | `auto`, `plain`, or `tty` |

### Examples

```bash
container build -t myapp:latest .
container build -t myapp:latest -f deploy/Dockerfile .
container build -t myapp:latest --build-arg NODE_ENV=production --target runtime .
```

## container image

Manage local images.

```bash
container image ls                         # list images
container image pull <image>               # pull from registry
container image push <image>               # push to registry
container image inspect <image>            # inspect image details
container image tag <src> <dst>            # tag an image
container image save -o <file.tar> <image> # export to tar
container image load <file.tar>            # import from tar
container image rm <image>                 # delete image
container image prune                      # remove unused images
```

## container (container management)

```bash
container ls                               # list running containers
container inspect <id>                     # detailed container info
container logs [-f] [-n lines] <id>        # fetch logs (-f to follow)
container exec [-it] <id> <cmd>            # run command in container
container stop <id>                        # stop container
container start <id>                       # start a stopped container
container kill <id>                        # force kill
container rm <id>                          # remove container
container prune                            # remove all stopped containers
container stats                            # resource usage
container cp <id>:<path> <local>           # copy from container
container cp <local> <id>:<path>           # copy to container
container export -o <file.tar> <id>        # export filesystem
```

## container volume

```bash
container volume create <name>
container volume ls
container volume inspect <name>
container volume rm <name>
container volume prune                     # remove unused volumes
```

## container network

```bash
container network create <name>
container network ls
container network inspect <name>
container network rm <name>
container network prune                    # remove unused networks
```

## container machine

Manage the VM that runs containers.

```bash
container machine ls
container machine start
container machine stop
```

## container registry

```bash
container registry login <registry>
container registry logout <registry>
```

---

# container-compose Reference

Reads standard Docker Compose YAML files.

```bash
container-compose [options] <command>
```

| Flag                | Description       |
| ------------------- | ----------------- |
| `-f, --file <path>` | Compose file path |

### Commands

```bash
container-compose up [-d] [--build]        # start services
container-compose down                     # stop and remove services
container-compose build [--no-cache]       # build images only
container-compose version                  # show version
```

### Examples

```bash
# Start all services detached
container-compose up -d

# Rebuild and start
container-compose up -d --build

# Use a specific compose file
container-compose -f docker-compose.dev.yml up -d

# Stop everything
container-compose down
```

### Compose file notes

- Standard Docker Compose syntax is supported (services, volumes, networks, ports, env, etc.).
- `build:` directive works — it delegates to `container build`.
- `volumes:` and `networks:` sections are supported.

---

# crane Reference

`crane` operates directly on OCI registries — no daemon required.

## Image discovery

```bash
crane catalog <registry>                   # list repos (e.g. crane catalog docker.io/library)
crane ls <repo>                            # list tags (e.g. crane ls docker.io/library/nginx)
crane ls <repo> -O                         # list tags, omit sha256-digest tags
```

## Image inspection

```bash
crane digest <image>                       # get image digest
crane digest <image> --full-ref            # full ref by digest
crane manifest <image>                     # print manifest JSON
crane manifest <image> | jq                # pretty-print
crane config <image>                       # image config (env, entrypoint, cmd, labels)
crane config <image> | jq '.config.Env'    # just environment variables
```

## Image transfer

```bash
crane copy <src> <dst>                     # copy image between registries
crane copy <src> <dst> -a                  # copy all tags
crane tag <image> <new-tag>                # add a tag remotely
crane delete <image>                       # delete image from registry
```

## Local operations

```bash
crane pull <image> <output.tar>            # pull image to local tarball
crane push <input.tar> <image>             # push local tarball to registry
crane export <image> <output.tar>          # export filesystem as tarball
```

## Image modification

```bash
crane mutate <image> --annotation key=val  # add annotation
crane append <image> --new_base <new> -t <out>  # rebase onto new base
crane flatten <image> -t <output.tar>      # flatten layers
crane validate --tarball <file.tar>        # validate image tarball
```

## Registry auth

```bash
crane auth login <registry> -u <user> -p <pass>
crane auth logout <registry>
```

### Examples

```bash
# Find available nginx tags
crane ls docker.io/library/nginx

# Check what env vars the image exposes
crane config docker.io/library/nginx:alpine | jq '.config.Env'

# Pin an image by digest
crane digest docker.io/library/node:20-slim
# → sha256:abc123...
# Use: docker.io/library/node@sha256:abc123...

# Mirror an image to a private registry
crane copy docker.io/library/nginx:latest registry.example.com/nginx:latest
```
