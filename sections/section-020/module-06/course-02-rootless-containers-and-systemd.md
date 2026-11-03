# Rootless Containers And systemd

Astronaut, a rootless container is a pod docked by a normal crew member with no captain's authority. This is the safer way to dock a pod, because a bug in the pod then reaches only what that crew member could reach. This part shows what the crew member needs, which limits apply, and how to keep the pod running after the crew member leaves.

## Run a container as a normal user

Start with a case you can run. The user `pilot` starts a pod with no `sudo`.

<!-- astrona:playground:renew -->

### See it in your playground

Open a full login for `pilot`. It gives `pilot` a proper user session, which later steps need:

```sh
sudo machinectl shell pilot@
```

As `pilot`, start a container and look at it:

```sh
podman run -d --name beacon -p 8081:80 docker.io/library/nginx:alpine
podman ps
```

The container runs as an ordinary process of the user `pilot`. Root did not start it.

## What a rootless container needs

A container usually sees a user with the ID 0 inside it, and other IDs too. A normal user may only be one ID on the ship, so Podman uses a **user namespace**: a map that shows a block of ship IDs to the pod as its own IDs. The blocks a user may use are listed in two files.

### The ID ranges

`/etc/subuid` and `/etc/subgid` list the **subordinate** user and group IDs of each account: the account name, the first ID and how many IDs. A user with no line in these files cannot run rootless containers that need more than one ID. Check the lines for `pilot`:

```sh
grep pilot /etc/subuid /etc/subgid
```

Each file has one line for `pilot`. If a user has none, an administrator adds a range with `sudo usermod --add-subuids <first>-<last> <user>` and the same with `--add-subgids`.

### Where the data lives

A rootless user keeps images and containers in the home folder, under `~/.local/share/containers`. This is why root and `pilot` do not see each other's images, and why a full home folder stops container builds.

## The lowest port

A normal user may not open a port below a limit. The kernel setting `net.ipv4.ip_unprivileged_port_start` holds that limit, and it is 1024 by default. Read it:

```sh
sysctl net.ipv4.ip_unprivileged_port_start
```

A command such as `podman run -p 80:80 ...` as `pilot` fails, because the host port 80 is below the limit. Use a high port such as 8081, or lower the setting as root, which then affects every user of the ship.

## Keep the pod after logout

The user's services run under a service manager that belongs to that user. When the user logs out, the manager stops, and the containers it started stop with it. **Lingering** keeps the manager running without a login, and starts it at boot. Switch it on as root, outside the `pilot` shell:

```sh
sudo loginctl enable-linger pilot
loginctl show-user pilot --property=Linger
```

The second command prints `Linger=yes` once lingering is on.

## Start the pod as a user service with Quadlet

A **Quadlet** file is a short duty card for a container. Podman turns it into a systemd service. Podman 4.9, which Ubuntu 24.04 ships, supports Quadlet. For every option you can use, read `man podman-systemd.unit`.

### Write the duty card

As `pilot`, make the folder, then save this as `/home/pilot/.config/containers/systemd/signal.container`:

```ini
[Unit]
Description=Signal web pod

[Container]
Image=docker.io/library/nginx:alpine
PublishPort=8082:80

[Install]
WantedBy=default.target
```

Apply it. This tells the user's duty officer to read the cards again and then starts the new service:

```sh
mkdir -p ~/.config/containers/systemd
systemctl --user daemon-reload
systemctl --user start signal.service
```

Then check the result:

```sh
systemctl --user status signal.service
podman ps
```

The service is named after the file: `signal.container` becomes `signal.service`. The `[Install]` section makes the pod start whenever the user's manager starts, which with lingering means at boot.

## Common pitfalls

> [!WARNING]
> - **Starting `podman` as root and expecting `pilot` to see it.** Each user has a separate store.
> - **`sudo -iu pilot` and `systemctl --user`.** That shell can lack the user bus, and `systemctl --user` then fails. Use `sudo machinectl shell pilot@`.
> - **Forgetting lingering.** The pod runs while you are logged in and dies at logout.
> - **Using a port below 1024.** The container does not start, or the port cannot be bound.

## Your mission: Rootless Podman Container Lab

You can now run a container as a normal user, publish a high port, and keep the user's containers running after logout. The mission asks you to do this on a fresh training ship for the user `pilot`.

The mission runs on its own training ship. Pause your playground first:

```sh
astrona stop podman-rootless-bay
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-06/labs/lab-01
astrona ssh ats-002-lab-026
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-06/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-026
astrona start podman-rootless-bay
```

*A rootless container needs an ID range in `/etc/subuid` and `/etc/subgid`, a port of 1024 or higher, and `loginctl enable-linger` to survive logout; a Quadlet `.container` file turns it into a user service.*
