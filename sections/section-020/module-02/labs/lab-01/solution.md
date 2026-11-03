# Solution Walkthrough

Follow these steps to stop one container, pull two exact facts out of another, and launch a third with exact limits. Add `sudo` in front of the `docker` commands if your user is not in the `docker` group.

---

## Step 1: Stop frontend_v1

```bash
docker stop frontend_v1
```

The Docker engine sends `SIGTERM` to the container's PID 1, waits up to the default 10-second grace period for it to exit, and sends `SIGKILL` only if it is still alive. This is the right default for "stop". Use `docker kill` only when a process really hangs and ignores `SIGTERM`. Do not run `docker rm`: the grader expects `frontend_v1` to still exist, in the `exited` state.

## Step 2: Prepare the output directory

```bash
mkdir -p /opt/course/11
```

Redirection with `>` does not create missing folders. This trips up more candidates than the Docker commands themselves. If your user may not write to `/opt`, work in a root shell (`sudo -i`) for this step and the next two, because the redirections in them also write under `/opt`.

## Step 3: Read frontend_v2's IP address

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' frontend_v2 > /opt/course/11/ip-address
```

`--format` runs a Go template against the same record that `docker inspect frontend_v2` would print as raw JSON. Docker fills `.NetworkSettings.IPAddress` for containers on the default bridge network. If the file ends up empty, the container is most likely on a network you created, and you need the per-network path:

```bash
docker inspect --format '{{ range .NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}' frontend_v2 > /opt/course/11/ip-address
```

`range` goes through the `Networks` map, so you do not need to know the network's name.

## Step 4: Read frontend_v2's mount destination

```bash
docker inspect --format '{{ (index .Mounts 0).Destination }}' frontend_v2 > /opt/course/11/mount-destination
```

`.Mounts` is a JSON list of mount entries. `index .Mounts 0` picks the first entry; the task says there is exactly one mount, so index `0` is safe and complete. `.Destination` on that entry is the path inside the container. To check the count first:

```bash
docker inspect --format '{{ len .Mounts }}' frontend_v2
# 1
```

## Step 5: Start frontend_v3 with a memory limit and a port mapping

```bash
docker run -d \
  --name frontend_v3 \
  --memory=30m \
  -p 1234:80 \
  nginx:alpine
```

`-d` detaches, so the container runs in the background. `--name` sets a fixed, readable name instead of a random one. `--memory=30m` makes the kernel cap the container's cgroup memory at 30 MiB; if the process inside tries to use more, the kernel's OOM killer (out-of-memory killer) ends it. `-p 1234:80` maps host port 1234 to container port 80. The left side of `-p` is always the host port; the right side is the port the process inside listens on.

## Step 6: Check the result

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

A command you typed correctly and a container that is really set up the way you meant are two different things. A typo in `-p` or `--memory` does not cause an error in the shell. Always check the running state, not the command you remember typing.

When the checks look right, send the lab for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

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
