# Docker Container Lifecycle: Inspect, Stop, and Launch

Astronaut, containers are sealed pods docked to your ship. Each one has its own crew and air but shares the ship's reactor core, the Linux kernel. The Docker engine is the docking bay crew that docks, starts and stops them on your orders.

Working with a container comes down to three skills. You need to know which state it is in and how each order moves it. You need to stop the process inside cleanly instead of just killing it. And you need to pull one exact fact out of the Docker engine's record instead of reading a wall of JSON. This module also shows how to launch a container with a memory limit and a port mapping, and how to prove both took effect.

## Learning objectives

After this module you can:

- Name the container states and the order that causes each change, and explain why stopping a container is not removing it.
- Explain what `docker stop` does, signal by signal, and why a shell-form `CMD` makes it wait the full grace period.
- Choose between `docker stop` and `docker kill`, and change the grace period with `-t`.
- Write `docker inspect --format` templates with field paths, `range`, `index` and `len`.
- Read a container's IP address whether it is on the default bridge network or on a network you created.
- Launch a detached container with a memory limit and a port mapping, with the `-p` direction right.
- Check the applied memory limit (in bytes) and the port mapping with `docker inspect` and `docker ps`, not from the command you typed.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands and use `sudo`.
- **What a process is.** A process is one running program, a crew member doing one job.
- **What JSON looks like.** JSON is a text format of names and values inside curly brackets, for example `{"Name": "web"}`.

### What you need

- A terminal on an Ubuntu 24.04 machine with Docker installed, if you want to try the examples in the parts. Add `sudo` to the `docker` commands if your user is not in the `docker` group.
- Or a running lab machine: the mission in this module gives you the exact commands to start it and open a terminal on it.

## How this module is laid out

1. [The Container Lifecycle And Stopping Cleanly](./course-01-the-container-lifecycle-and-stopping.md): the created, running, paused, exited and dead states, why `docker stop` leaves a container `exited` instead of removed, the `SIGTERM`, grace period, `SIGKILL` sequence, and when `docker kill` is the right call.
2. [Inspecting With --format](./course-02-inspecting-with-format.md): the two halves of the `docker inspect` record, the Go template language (`range`, `index`, `len`), IP addresses per network, and reading a mount from a list.
3. [Launching With Limits](./course-03-launching-with-limits.md): `docker run` with `--memory` and `-p`, and checking the limits in the Docker engine's record.
   - Mission: [Docker Container Lifecycle Lab](./labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

On the exam, and on a real server, a container that "looks fine" is not proof. A stop that removes too much, a port mapping turned the wrong way round or a memory limit that never applied all fail without an error. These parts teach you to give the right order and then read the result back from the Docker engine itself.
