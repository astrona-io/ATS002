# Podman And Rootless Containers

Astronaut, the Docker engine is a docking bay crew that stays on duty all the time, and it works as the captain. Podman is another way to dock pods. It has no standing crew: every `podman` command starts the pod's own small monitor and then steps away. Podman can also dock pods for an ordinary crew member, with no captain's authority at all. That is called a **rootless** container.

This module teaches the Podman commands, which look almost the same as the Docker ones, and the extra things rootless containers need: a range of user IDs, a storage folder in the home folder, a lowest port number, and a way to keep the pod running after the crew member leaves.

## Learning objectives

After this module you can:

- Explain that Podman needs no background daemon, and use `podman run`, `ps`, `images` and `pull` the way you use the Docker commands.
- Write a fully qualified image name such as `docker.io/library/nginx:alpine`, and say what `unqualified-search-registries` in `/etc/containers/registries.conf` is for.
- Run a container as a normal user, and say where its images and containers are kept.
- Explain what `/etc/subuid` and `/etc/subgid` are for.
- Explain why a normal user cannot publish a port below 1024 by default, and which kernel setting controls it.
- Keep a normal user's containers running after logout with `loginctl enable-linger`.
- Write a Quadlet `.container` file that starts a container as a user service.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands, use `sudo` and save a text file.
- **What a container is.** A container is a sealed pod docked to your ship. It shares the ship's reactor core, the Linux kernel.
- **What a systemd service is.** A service is a station that the duty officer `systemd` starts and watches.

### What you need

- A terminal on an Ubuntu 24.04 machine with the `podman` package installed, or the playground below.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship. Podman is installed, and so are the helpers that rootless containers need. A normal user called `pilot` is on the crew roster, with lingering already switched on. There are no images yet, so the first `podman pull` downloads one. It is a throwaway ship, so experiment freely.

Start the playground with `astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-06/playground`, then open a terminal on it with `astrona ssh astro-podman-rootless-bay`. To work as `pilot`, run `sudo machinectl shell pilot@`. When you are finished, remove the playground with `astrona destroy podman-rootless-bay` (that command takes the name `podman-rootless-bay`, without the `astro-` prefix).

<!-- astrona:playground -->

## How this module is laid out

1. [Podman As A Docker-Compatible Engine](./course-01-podman-as-a-docker-compatible-engine.md): no daemon, the familiar commands, and fully qualified image names.
2. [Rootless Containers And systemd](./course-02-rootless-containers-and-systemd.md): user IDs, rootless storage, the lowest port, lingering, and Quadlet files.
   - Mission: [Rootless Podman Container Lab](./labs/lab-01/question.md)
3. [Wrap-Up: Mission Debrief](./course-03-wrap-up.md)

## Why this matters

On many Linux distributions, Podman is the container tool that ships by default, and the exam expects you to work with containers without assuming Docker. Rootless containers add four silent failures: a missing ID range, a port below 1024, a container that dies at logout and an image name that no registry list resolves. This module shows each one and how to fix it.

<!-- curriculum-practice -->
## Practice and assessment

- [Rootless Podman Container Lab](labs/lab-01/question.md): Run a rootless Podman container with a published high port; Save a container's image ID with podman inspect; Keep a user's services running after logout with enable-linger.
- [Scheduled Container Recovery Capstone Lab](../capstone/labs/lab-01/question.md): Remove a container that holds a host port and start its replacement with limits; Schedule a per-user watchdog script that restarts the container when it stops.
