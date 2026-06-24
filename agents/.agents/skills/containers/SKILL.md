---
name: containers
description:
  Run and manage containers, build images on macOS. Use when the user asks about containers, Dockerfiles, compose files,
  container images, registries, or containerized services.
---

# Container

## Key Rules

1. **Prefer `container` over `docker`.** On macOS, use Apple's native [container](https://github.com/apple/container)
   CLI instead of Docker engine. It runs containers via Virtualization.framework — no Linux VM overhead.
2. **Prefer `container-compose` over `docker-compose`.** It reads standard Docker Compose files but uses the native
   `container` runtime.
3. **Use `crane` for image search and registry operations.** It talks directly to OCI registries without needing a
   daemon.

You can use regular `docker` commands when user explicitly asks for it or if there are some issues with `container` CLI.
`docker` or `docker compose` commands are appropriate choice when using remote docker engine via docker context.

## Quick Command Map

| Docker equivalent   | Use instead                  |
| ------------------- | ---------------------------- |
| `docker run`        | `container run`              |
| `docker build`      | `container build`            |
| `docker ps`         | `container ls`               |
| `docker logs`       | `container logs`             |
| `docker exec`       | `container exec`             |
| `docker pull/push`  | `container image pull/push`  |
| `docker compose up` | `container-compose up`       |
| `docker search`     | `crane catalog` / `crane ls` |

## Common Workflows

### Run a container

```bash
container run -d --name myapp -p 8080:80 nginx
container run -it --rm alpine sh
```

### Build an image

```bash
container build -t myapp:latest .
container build -t myapp:latest -f Dockerfile.prod --no-cache .
```

### Compose services

```bash
container-compose up -d
container-compose down
container-compose -f docker-compose.dev.yml up -d --build
```

### Search / inspect images with crane

```bash
crane catalog docker.io/library          # list repos in a registry
crane ls docker.io/library/nginx         # list tags for a repo
crane digest nginx:latest                # get image digest
crane manifest nginx:latest              # inspect manifest
crane config nginx:latest                # view image config (env, entrypoint, etc.)
```

### Manage running containers

```bash
container ls                             # list running containers
container logs -f myapp                  # follow logs
container exec -it myapp sh              # shell into container
container stop myapp                     # stop
container delete myapp                   # remove
container prune                          # remove all stopped containers
```

### Volumes & networks

```bash
container volume create data
container volume ls
container network create mynet
container run --network mynet --name web nginx
```

## Notes

- `container` only supports **Linux** containers (runs via a lightweight VM on macOS).
- Port mapping uses `-p host:container` just like Docker.
- For bind mounts use `--mount type=bind,source=/host/path,target=/container/path`.
- `--init` adds a PID 1 init process — useful for proper signal handling.
- For detailed command reference, see [REFERENCE.md](REFERENCE.md).
