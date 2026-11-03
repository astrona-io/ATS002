# Podman As A Docker-Compatible Engine

Astronaut, you already know how to dock a pod with the Docker engine. Podman gives you the same orders, but it works without a docking crew on permanent duty. This part shows the commands you can reuse, and the one habit that always changes: writing the full name of the crate you want.

## No daemon, same commands

The Docker engine, `dockerd`, is one program that keeps running and does all the work for every container. Podman has no such program. Each `podman` command does its work itself and starts a small monitor, `conmon`, next to each container. The container keeps running after the command ends.

The commands you know keep their names and options. Start with a case you can run.

<!-- astrona:playground:renew -->

### See it in your playground

Pull an image and start a container from it. The commands run with `sudo` here, so Podman works as the captain:

```sh
sudo podman pull docker.io/library/nginx:alpine
sudo podman run -d --name web -p 8080:80 docker.io/library/nginx:alpine
```

List the images and the running containers:

```sh
sudo podman images
sudo podman ps
```

The lists have the same columns idea as `docker images` and `docker ps`: the image name and tag, the container name, the status and the port mapping. Stop and remove the container the way you would with Docker:

```sh
sudo podman stop web
sudo podman rm web
```

`podman stop` sends `SIGTERM` first and then `SIGKILL` after a grace period, as `docker stop` does.

## Fully qualified image names

A **fully qualified image name** says which registry holds the image: `docker.io/library/nginx:alpine` is the registry `docker.io`, the namespace `library`, the image `nginx` and the tag `alpine`. A **short name** such as `nginx:alpine` leaves the registry out.

Docker quietly assumes one registry for short names. Podman reads a list of registries from `/etc/containers/registries.conf`. The setting `unqualified-search-registries` holds the registries it may try for a short name.

### Check what your ship allows

Show the lines that are not comments:

```sh
grep -v '^#' /etc/containers/registries.conf
```

Read what the output says about `unqualified-search-registries` on your own machine. If the list is empty, or there is more than one registry, a short name can fail or ask which registry you mean. The safe habit is always to write the fully qualified name, because it works the same on every machine.

## Where Docker and Podman differ

- Podman has no `dockerd`, so there is no socket to give a user access to, and no `docker` group.
- Containers started by one user are invisible to another user. Each user has a separate store.
- `podman` can read many Docker commands unchanged, but build files and options can differ in details. Check `man podman-run` for an option you do not know.

## Common pitfalls

> [!WARNING]
> - **Using a short image name.** `podman pull nginx` may fail or ask a question, depending on the registries list. Write `docker.io/library/nginx`.
> - **Looking for a container as another user.** `sudo podman ps` does not show the containers that `pilot` started. Each user has their own list.
> - **Expecting a Docker daemon.** Commands such as `systemctl status docker` say nothing about Podman.

*Podman needs no daemon and takes the Docker commands almost as they are; write the fully qualified image name, and remember that each user has a separate store.*
