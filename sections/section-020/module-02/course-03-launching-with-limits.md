# Launching With Limits

Astronaut, a new pod should dock with clear limits: how much of the ship's memory it may use, and which of the ship's radio channels lead to it. This part shows how to start a detached container with a memory limit and a port mapping, and how to prove from the Docker engine's own record that both limits took effect.

## Launching with an exact limit

One `docker run` command sets the name, the memory limit and the port mapping together. A **port** is a radio channel: only one station on the ship can listen on one channel. A **port mapping** patches one of the ship's channels through to a channel inside the pod.

### Start the container

Start an `nginx:alpine` container named `api_demo` with a 128 MB memory limit, and patch the ship's port 8080 through to the pod's port 80 (add `sudo` if your user is not in the `docker` group):

```bash
docker run -d \
  --name api_demo \
  --memory=128m \
  -p 8080:80 \
  nginx:alpine
```

### What each option does

- **`-d`** (detach): the container runs in the background, and you get your prompt back.
- **`--name api_demo`**: a fixed name instead of a random one such as `adjective_scientist`.
- **`--memory=128m`**: the kernel caps the container's cgroup memory at 128 MiB. If the process inside tries to use more, the kernel's OOM killer (out-of-memory killer) ends it instead of letting it grow. Docker stores the limit in **bytes**.
- **`-p 8080:80`**: maps **host** port 8080 to **container** port 80. The left number is always the host side; the right number is the port the process inside listens on. Swap them and you publish a host port that leads to nothing.

## Check the running state, not the command you typed

A typo in `-p` or `--memory` does not cause an error in your shell. Check what the Docker engine actually built.

### Read the limits back

Run these three checks:

```bash
docker ps --filter 'name=api_demo'
docker inspect --format '{{ .HostConfig.Memory }}' api_demo
docker stats --no-stream api_demo
```

- `docker ps --filter` lists only matching containers. Its `PORTS` column shows `0.0.0.0:8080->80/tcp` if the mapping took.
- `{{ .HostConfig.Memory }}` prints the limit in bytes. 128 MiB is `134217728` (`128 × 1024 × 1024`). A value of `0` means no limit was set.
- `docker stats --no-stream` prints one snapshot of live memory use against the limit, instead of a screen that keeps updating.

## Common pitfalls

> [!WARNING]
> - **A reversed `-p` mapping.** `-p 80:8080` publishes host port 80 to container port 8080, where nothing listens. The host port is always on the left.
> - **Reading `.HostConfig.Memory` as megabytes.** It is bytes: `134217728`, not `128`. Convert before you call it wrong.
> - **Trusting the command you typed.** Read the limits back from `docker inspect` and `docker ps`, because a typo fails silently.

## Your mission: Docker Container Lifecycle Lab

You can now stop a container cleanly, pull one fact out of its record with `--format`, and launch a container with a memory limit and a port mapping. The mission asks you to stop one container, save two facts about another one into files, and start a third container with exact limits.

The mission runs on its own training ship. Start it and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-02/labs/lab-01
astrona ssh ats-002-lab-022
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-022
```
