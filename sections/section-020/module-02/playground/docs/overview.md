# Overview: Docker Container Lifecycle Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one docking bay, with one pod already docked:

- A single Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-docker-lifecycle-bay`.
- The Docker engine, enabled and running. Use `sudo` in front of `docker` unless your user is in the `docker` group.
- The image `nginx:alpine`, already pulled.
- One running container named `web_demo`, started from `nginx:alpine` with the host folder `/opt/web_demo/html` mounted at `/usr/share/nginx/html`. It is on the default bridge network, so it has one mount and an IP address to read.
- No `api_demo` container yet: the launching examples create it.

## Things to try

- Run `docker ps` and `docker ps -a` and compare the lists.
- Run `docker stop web_demo`, then `docker ps -a`: the container is `Exited`, not removed. `docker start web_demo` brings it back.
- Read its record with `docker inspect web_demo`, then pull out single facts: `docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' web_demo` and `docker inspect --format '{{ (index .Mounts 0).Destination }}' web_demo`.
- Launch a limited container: `docker run -d --name api_demo --memory=128m -p 8080:80 nginx:alpine`, then read `.HostConfig.Memory` back (it is in bytes) and `docker ps`.
- Try `docker kill --signal=HUP web_demo` and `docker kill web_demo`, and see the difference from `docker stop`.

## When you're done

```sh
astrona destroy docker-lifecycle-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-docker-lifecycle-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `docker-lifecycle-bay`.
