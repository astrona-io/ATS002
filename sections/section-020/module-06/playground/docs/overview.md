# Overview: Podman And Rootless Containers Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

- A single Ubuntu 24.04 `qemu` virtual machine, your docking bay. Reach it with `astrona ssh astro-podman-rootless-bay`.
- **Podman**, installed from the Ubuntu packages, with `uidmap`, `slirp4netns` and `systemd-container` (which provides `machinectl`).
- The user **`pilot`**, a normal account with a range of subordinate user and group IDs in `/etc/subuid` and `/etc/subgid`.
- Lingering is already enabled for `pilot`, so the user's service manager keeps running without a login.
- No images and no containers yet. Pulling an image needs the machine to reach the registry.

Open a full login for `pilot` with:

```sh
sudo machinectl shell pilot@
```

This gives `pilot` a proper user session, which `systemctl --user` needs. Type `exit` to come back.

## Things to try

- As root, run `sudo podman pull docker.io/library/nginx:alpine` and `sudo podman images`, and compare with the same commands as `pilot`. The two users have separate image stores.
- As `pilot`, run `podman run -d --name beacon -p 8081:80 docker.io/library/nginx:alpine` and `podman ps`.
- As `pilot`, try `-p 80:80` and see what happens when a normal user asks for a port below 1024.
- Run `sysctl net.ipv4.ip_unprivileged_port_start` to see the lowest port a normal user may use.
- Save a Quadlet file at `~/.config/containers/systemd/signal.container`, run `systemctl --user daemon-reload` and `systemctl --user start signal.service`.

## When you're done

```sh
astrona destroy podman-rootless-bay
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-podman-rootless-bay`; the `astro-` prefix is optional there. The name for `astrona destroy` is `podman-rootless-bay`.
