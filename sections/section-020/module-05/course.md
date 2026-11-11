# Container Images, Volumes And Networks

Astronaut, a container is a sealed pod, and a container image is the sealed crate the pod is made from. Until now you docked pods that someone else packed. In this module you pack your own crate, give a pod a cargo hold that outlives it, and patch pods together over their own radio network.

Three skills make up the module. You build an image from a `Dockerfile`, a plain text fitting plan. You keep data safe with a volume or a bind mount, a hatch between a pod and one of the ship's cargo holds. And you put pods on a network of your own, read their logs and step inside them with `docker exec`.

## Learning objectives

After this module you can:

- Write a `Dockerfile` with `FROM`, `COPY`, `RUN`, `EXPOSE` and `CMD`, and build and tag an image from it with `docker build -t`.
- Explain the difference between the exec form and the shell form of `CMD`.
- Read the layers of an image with `docker history`.
- Choose between a named volume and a bind mount, and create, list and inspect volumes.
- Explain why data in a named volume stays after `docker rm` and goes only with `docker volume rm`.
- Create a user-defined network, start containers on it, and explain why they find each other by name there but not on the default bridge.
- Read a container's output with `docker logs`, open a shell in it with `docker exec -it`, and remove containers and images without removing too much.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands, use `sudo` and save a text file.
- **What a container is.** A container is a sealed pod docked to your ship. It has its own crew and air, and it shares the ship's reactor core, the Linux kernel.
- **How to start a container.** You know `docker run -d --name <name> <image>`.

### What you need

- A terminal on an Ubuntu 24.04 machine with Docker installed, or the playground below. Add `sudo` to the `docker` commands if your user is not in the `docker` group.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship that acts as the docking bay. Docker is running, the images `nginx:alpine` and `alpine` are already pulled, and the folder `/opt/demo/status-page` holds one web page, `index.html`. You have no containers, volumes or networks of your own yet. Because the playground is a real machine, your builds and containers really run. It is a throwaway ship, so experiment freely.

Start the playground with `astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-05/playground`, then open a terminal on it with `astrona ssh astro-container-build-bay`. When you are finished, remove it with `astrona destroy container-build-bay` (that command takes the name `container-build-bay`, without the `astro-` prefix).

<!-- astrona:playground -->

## How this module is laid out

1. [Building An Image From A Dockerfile](./course-01-building-an-image-from-a-dockerfile.md): the instructions of a `Dockerfile`, `docker build -t`, `docker images`, `docker history`, and exec form against shell form.
2. [Volumes And Bind Mounts](./course-02-volumes-and-bind-mounts.md): named volumes against bind mounts, `docker volume create`, `ls` and `inspect`, `-v` and `--mount`, and what survives `docker rm`.
3. [Networks, Logs And Exec](./course-03-networks-logs-and-exec.md): user-defined networks and name lookup, `-p`, `docker logs`, `docker exec -it`, and removing containers and images.
   - Mission: [Container Images, Volumes And Networks Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A container that runs is only half the job. The exam asks you to build an image that holds exactly what a task names, keep its data when the container goes away, and put it on the right network. Each of these fails without an error: a build with the wrong tag, a volume that was never mounted, a network that was never joined. These parts teach you to build, mount and connect, and then read the result back from Docker.

<!-- curriculum-practice -->
## Practice and assessment

- [Container Images, Volumes And Networks Lab](labs/lab-01/question.md): Build an image from a Dockerfile with a tag; Create a named volume and a user-defined network; Run a container that uses the volume and the network.
- [Scheduled Container Recovery Capstone Lab](../capstone/labs/lab-01/question.md): Remove a container that holds a host port and start its replacement with limits; Schedule a per-user watchdog script that restarts the container when it stops.
