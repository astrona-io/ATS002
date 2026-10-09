# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the states a container moves through, the orders that stop it, the Docker engine's record of it, and launching it with limits.

**From [The Container Lifecycle And Stopping Cleanly](./course-01-the-container-lifecycle-and-stopping.md):**

- `docker run` is create plus start. A container is created, running, paused, exited or dead.
- `docker stop` leaves a container `exited`, not removed. Only `docker rm` deletes it.
- `docker stop` sends `SIGTERM` to PID 1, waits the grace period (10 seconds by default, `-t` to change it), then sends `SIGKILL`.
- A shell-form `CMD` puts `/bin/sh` in as PID 1, which does not pass `SIGTERM` on. `docker run --init` fixes that.
- `docker kill` sends `SIGKILL` at once. Use it only for a container that hangs.

**From [Inspecting With --format](./course-02-inspecting-with-format.md):**

- `docker inspect` prints the full record: `.Config` from create time, and `.State`, `.NetworkSettings`, `.Mounts` and `.HostConfig` kept up to date while it runs.
- `--format` runs a Go template: field paths, `range`, `index`, `len`, `json` and `printf`.
- `.NetworkSettings.IPAddress` is only filled on the default bridge. `range .NetworkSettings.Networks` works on any network.
- Count a list with `len .Mounts` before you pick an item with `index .Mounts 0`.

**From [Launching With Limits](./course-03-launching-with-limits.md):**

- `docker run -d --name <name> --memory=<size> -p <host>:<container> <image>` starts a detached container with a memory limit and a port mapping.
- The host port is always on the left of `-p`.
- `.HostConfig.Memory` is in bytes, and `docker ps` shows the port mapping in its `PORTS` column.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Docker Container Lifecycle Lab](./labs/lab-01/README.md) | Launching With Limits | stopped a container, saved its neighbour's IP address and mount path with `--format`, and launched a container with a memory limit and a port mapping |

If you skipped it, go back to it now. It is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A task says "stop the container <code>cache_v1</code>". Which command do you use, and what state is the container in afterwards?</summary>

`docker stop cache_v1`. The container ends up `exited`. It still exists, and `docker ps -a` lists it.
</details>

<details>
<summary>2. What does <code>docker stop</code> do, step by step?</summary>

It sends `SIGTERM` to the container's PID 1, waits up to the grace period (10 seconds by default), and sends `SIGKILL` if the process is still alive.
</details>

<details>
<summary>3. Why does <code>docker stop</code> take the full 10 seconds on a container started with <code>CMD nginx</code>?</summary>

The shell form makes `/bin/sh -c nginx` PID 1, and `sh` does not pass `SIGTERM` on to `nginx`. After the grace period, `SIGKILL` ends it. Use the exec form `CMD ["nginx"]` or `docker run --init`.
</details>

<details>
<summary>4. <code>docker inspect --format '{{ .NetworkSettings.IPAddress }}' app</code> prints nothing, but the container is running. Why, and what do you run instead?</summary>

The container is not on the default bridge network, so the top-level field is empty. Use `docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' app`.
</details>

<details>
<summary>5. Which template prints the path inside the container of its first mount?</summary>

`{{ (index .Mounts 0).Destination }}`. Check the count first with `{{ len .Mounts }}`.
</details>

<details>
<summary>6. You need host port 5000 to reach port 80 inside the container. Which <code>-p</code> option do you write?</summary>

`-p 5000:80`. The host port is always on the left.
</details>

<details>
<summary>7. <code>docker inspect --format '{{ .HostConfig.Memory }}'</code> prints <code>52428800</code>. Which <code>--memory</code> value was used?</summary>

`50m`. The value is in bytes, and 50 × 1024 × 1024 = 52428800.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-022
```
