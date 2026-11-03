# Overview: Container Images, Volumes And Networks Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

- A single Ubuntu 24.04 `qemu` virtual machine, your docking bay. Reach it with `astrona ssh astro-container-build-bay`.
- **Docker**, installed and running. Add `sudo` in front of `docker` if your user is not in the `docker` group.
- The images `nginx:alpine` and `alpine`, already pulled.
- The folder `/opt/demo/status-page` with one file, `index.html`. Anyone may write in the folder, so you can save a `Dockerfile` next to it.
- No containers, volumes or networks of your own yet.

## Things to try

- Save a `Dockerfile` that starts `FROM nginx:alpine` and copies `index.html` into `/usr/share/nginx/html/`. Build it with `docker build -t status-page:1.0 /opt/demo/status-page` and run it with `docker run -d --name page -p 8080:80 status-page:1.0`.
- Run `docker history status-page:1.0` and find the layer your `COPY` line made.
- Create a volume with `docker volume create notes`, start a container with `-v notes:/data`, write a file in `/data`, remove the container with `docker rm -f`, and start a new one with the same volume. The file is still there.
- Create a network with `docker network create appnet`. Start two containers on it and reach one from the other by name with `docker exec`.
- Read a container's output with `docker logs --tail 5 <name>` and open a shell in it with `docker exec -it <name> sh`.

## When you're done

```sh
astrona destroy container-build-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-container-build-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `container-build-bay`.
