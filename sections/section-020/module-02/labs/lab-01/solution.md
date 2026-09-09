# Solution Walkthrough

Follow these steps to stop a container, extract precise facts from another, and launch a third with exact constraints.

---

## Step 1: Stop frontend_v1

```bash
docker stop frontend_v1
```

This sends `SIGTERM` to the container's PID 1, waits up to the default 10-second grace period for it to exit on its own, and only sends `SIGKILL` if it hasn't. This is the correct default for "stop" — reach for `docker kill` only when a process is genuinely hung and ignoring termination signals.

## Step 2: Prepare the output directory

```bash
mkdir -p /opt/course/11
```

Redirection doesn't create parent directories — this trips up more candidates than the Docker commands themselves.

## Step 3: Extract frontend_v2's IP address

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2 > /opt/course/11/ip-address
```

`--format` runs a Go template against the same structure `docker inspect frontend_v2` would otherwise print as raw JSON. `.NetworkSettings.IPAddress` is populated for containers on the classic default bridge network. If this comes back empty instead, the container is very likely on a custom user-defined network, in which case you need the per-network path:

```bash
docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' frontend_v2 > /opt/course/11/ip-address
```

`range` iterates the `Networks` map without you needing to know the network's name in advance.

## Step 4: Extract frontend_v2's volume mount destination

```bash
docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2 > /opt/course/11/mount-destination
```

`.Mounts` is a JSON array of mount objects. `index .Mounts 0` addresses the first element generically — the task states there is exactly one mount, so index `0` is safe and complete — and `.Destination` on that object is the in-container path. To double-check the count first:

```bash
docker inspect --format '{{ len .Mounts }}' frontend_v2
# 1
```

## Step 5: Start frontend_v3 with a memory limit and port mapping

```bash
docker run -d \
  --name frontend_v3 \
  --memory=30m \
  -p 1234:80 \
  nginx:alpine
```

`-d` detaches so the container runs in the background. `--name` fixes a human-readable name instead of a random one. `--memory=30m` caps the container's cgroup memory at 30 megabytes — if the process inside tries to exceed it, the kernel's OOM killer terminates it rather than letting usage grow unbounded. `-p 1234:80` maps host port 1234 to container port 80 — the left side of `-p` is always the host-facing port, the right side is what the process inside is actually listening on.

## Step 6: Verify

```bash
docker ps -a --filter "name=frontend_v1"
# STATUS column shows "Exited (0) ..." — confirms stopped, not removed

cat /opt/course/11/ip-address
cat /opt/course/11/mount-destination

docker ps --filter "name=frontend_v3"
# PORTS column: 0.0.0.0:1234->80/tcp

docker inspect --format '{{ .HostConfig.Memory }}' frontend_v3
# 31457280   (30 * 1024 * 1024 bytes = 30MB)
```

A command you typed correctly and a container that's actually configured the way you intended are two different things — a typo in `-p` or `--memory` fails silently from the shell's point of view. Always verify against the running state, not the command you remember typing.

---

## Command Summary

```bash
docker stop frontend_v1
mkdir -p /opt/course/11
docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2 > /opt/course/11/ip-address
docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2 > /opt/course/11/mount-destination
docker run -d --name frontend_v3 --memory=30m -p 1234:80 nginx:alpine
docker ps --filter "name=frontend_v3"
docker inspect --format '{{ .HostConfig.Memory }}' frontend_v3
```

Once verified, run the local validation suite to pass the lab!
