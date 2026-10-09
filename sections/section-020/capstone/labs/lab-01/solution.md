# Solution Walkthrough

This capstone joins the two skills of the section. First you retire and launch containers with exact limits. Then you wrap the result in a per-user cron job that keeps the new container alive.

---

## Step 1: Retire billing_v1

```bash
sudo docker stop billing_v1
sudo docker rm billing_v1
```

`docker stop` gives the process a clean shutdown: `SIGTERM`, a grace period, and `SIGKILL` only if it is still running. `docker rm` then removes the container itself. The task asks for both, and the grader checks that `billing_v1` no longer exists. A stopped container no longer listens on port 9090, but it still has `-p 9090:80` in its settings, so anyone who starts it again would fight `billing_v2` for the port. Removing it ends that risk.

## Step 2: Launch billing_v2 with the required limits

```bash
sudo docker run -d \
  --name billing_v2 \
  --memory=64m \
  -p 9090:80 \
  nginx:alpine
```

`-d` detaches. `--memory=64m` makes the kernel cap the container's cgroup memory at 64 MiB. `-p 9090:80` maps host port 9090 (now free) to container port 80, where `nginx:alpine` listens by default.

Check it before you move on:

```bash
sudo docker ps --filter "name=billing_v2"
sudo docker inspect --format '{{ .HostConfig.Memory }}' billing_v2
# 67108864   (64 * 1024 * 1024 bytes)
```

## Step 3: Write the health-check script

Save this as `/home/ops-monitor/watch-billing.sh` (for example with `sudo nano /home/ops-monitor/watch-billing.sh`):

```bash
#!/usr/bin/env bash
if [ "$(docker inspect -f '{{ .State.Running }}' billing_v2 2>/dev/null)" != "true" ]; then
  docker start billing_v2
fi
```

Apply it:

```bash
sudo chmod 755 /home/ops-monitor/watch-billing.sh
sudo chown ops-monitor:ops-monitor /home/ops-monitor/watch-billing.sh
```

`docker inspect -f '{{ .State.Running }}'` asks one exact question: is the container running right now? `-f` is the short form of `--format`. If the container is not running (stopped or crashed), `docker start` brings the *same* container back up instead of creating a new one. `docker run` would be the wrong tool here, because it would clash with the name that already exists.

`ops-monitor` needs to be in the `docker` group for this to work without a password prompt. The lab setup already did that. Without it, `docker start` inside the cron job would fail with a permission error on the Docker socket, and you would only see that failure if you went looking in cron's mail or the logs.

## Step 4: Schedule it in ops-monitor's crontab, every minute

```bash
sudo crontab -u ops-monitor -e
```

Add:

```cron
* * * * * bash /home/ops-monitor/watch-billing.sh
```

Five stars mean "every minute of every hour of every day". That is the right pace for a health check that must notice a crash quickly. `-u ops-monitor` is what makes this `ops-monitor`'s crontab instead of root's own, and a per-user line has no username field.

## Step 5: Prove the recovery works

Do not just trust that the cron line looks right. Cause the failure it is meant to catch:

```bash
sudo docker stop billing_v2
sleep 65
sudo docker ps --filter "name=billing_v2"
# should show billing_v2 back in the Up state within about a minute
```

If it does not come back, check that `ops-monitor`'s crontab was saved (`sudo crontab -u ops-monitor -l`), that the script is executable, and that `sudo -u ops-monitor docker ps` does not fail with a permission error on the Docker socket.

When the container comes back on its own, send the lab for grading:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

---

## Command Summary

```bash
sudo docker stop billing_v1
sudo docker rm billing_v1
sudo docker run -d --name billing_v2 --memory=64m -p 9090:80 nginx:alpine

# save /home/ops-monitor/watch-billing.sh (see Step 3), then:
sudo chmod 755 /home/ops-monitor/watch-billing.sh
sudo chown ops-monitor:ops-monitor /home/ops-monitor/watch-billing.sh

sudo crontab -u ops-monitor -e
# add: * * * * * bash /home/ops-monitor/watch-billing.sh

sudo docker stop billing_v2
sleep 65
sudo docker ps --filter "name=billing_v2"
```
