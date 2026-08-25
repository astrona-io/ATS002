# Docker Container Lifecycle: Inspect, Stop, and Launch

`docker inspect` on a busy container dumps a wall of JSON that can run past a hundred lines. Reading it by eye is like being handed a ship's entire cargo manifest when all you actually needed to know was which container the sunscreen is in. `docker inspect` without a format is for humans skimming the whole manifest. `docker inspect --format` is for asking one precise question and getting back exactly one answer — nothing more.

## Stopping a Container Gracefully

`docker stop` sends `SIGTERM` to the container's PID 1, waits up to a default ten-second grace period for it to exit cleanly, and only sends `SIGKILL` if it's still alive after that. This is the correct default whenever a task tells you to "stop" something.

```bash
docker stop frontend_v1
```

`docker kill` skips straight to `SIGKILL` with no grace period at all. Reach for it only when a process is genuinely hung and ignoring termination signals — using it as your default is like unplugging a computer instead of shutting it down, every single time, just because it's faster.

---

## Reading the Manifest with `--format`

`docker inspect --format` runs a Go template against the same JSON structure `docker inspect` would otherwise print in full, and prints only the field path you ask for.

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2
```

`.NetworkSettings.IPAddress` holds the container's address when it's attached to the classic default bridge network. If that comes back empty, the container is very likely sitting on a custom, user-defined network instead — Docker only populates the top-level field for default-bridge containers, because once you're off the default bridge it tracks addresses per-network instead. The escape hatch is `range`, which iterates the `Networks` map without you needing to know the network's name in advance:

```bash
docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' frontend_v2
```

### Addressing Arrays Without Hardcoding

A container's volume mounts live under `.Mounts`, a JSON array. If a task tells you a container "has one" mount, you still shouldn't hardcode an index you had to eyeball first — `index` addresses the array element generically:

```bash
docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2
```

`index .Mounts 0` grabs the first (and here, only) mount object; `.Destination` on that object is the in-container path. If you want to double-check the count before committing to an index, `{{ len .Mounts }}` answers that directly.

---

## Launching With Constraints

Starting a new container with an exact resource ceiling and a network mapping is one command with several flags stacked together:

```bash
docker run -d \
  --name frontend_v3 \
  --memory=30m \
  -p 1234:80 \
  nginx:alpine
```

`-d` detaches — the container runs in the background and you get your terminal back immediately instead of watching its stdout scroll by. `--name` fixes a human-readable name instead of a random one Docker would otherwise generate. `--memory=30m` caps the container's cgroup memory at 30 megabytes; if the process inside tries to exceed that ceiling, the kernel's OOM killer terminates it rather than letting memory usage grow unbounded. `-p 1234:80` maps host port 1234 to container port 80 — the left side of a `-p` mapping is always the host-facing port, the right side is what the process inside is actually listening on. Reverse them and you'll be knocking on a host port nothing is bound to.

## Verifying What You Actually Built

A command you typed correctly and a container that's actually configured the way you intended are two different things — a typo in `-p` or `--memory` fails silently from the shell's point of view. Always check the running state:

```bash
docker ps --filter "name=frontend_v3"
docker inspect --format '{{ .HostConfig.Memory }}' frontend_v3
docker stats --no-stream frontend_v3
```

`docker ps` with a name filter shows the PORTS column mapped as you expect. `docker inspect --format '{{ .HostConfig.Memory }}'` reports the memory ceiling in raw bytes (30 megabytes shows up as `31457280`). `docker stats --no-stream` gives you a single-shot snapshot of live memory usage against that limit, without leaving a continuously-updating pane open.

---

## Self-Check and Verification

To prove your container lifecycle work is correct:

1. Stop a running container and confirm with `docker ps -a` that its STATUS shows `Exited`, not that it's been removed.
2. Use `docker inspect --format` to extract a second container's IP address, falling back to the `range .NetworkSettings.Networks` form if the top-level field is empty.
3. Use `index` against the `.Mounts` array to extract a volume mount destination without eyeballing raw JSON.
4. Launch a new detached container with a memory limit and a port mapping in a single `docker run -d` command.
5. Verify the memory limit and port mapping actually took effect using `docker inspect --format` and `docker ps`, not just by trusting the command you typed.
