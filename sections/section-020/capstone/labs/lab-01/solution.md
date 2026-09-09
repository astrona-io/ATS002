# Solution Walkthrough

This capstone connects both section skills: retiring and launching containers with exact constraints, then wrapping the result in a per-user cron job that keeps it alive.

---

## Step 1: Retire billing_v1

```bash
sudo docker stop billing_v1
sudo docker rm billing_v1
```

`docker stop` gives the process a clean SIGTERM/grace-period shutdown; `docker rm` then removes the container object entirely — required here because a *stopped* container still holds its port binding reserved until it's removed, and `billing_v2` needs that exact host port.

## Step 2: Launch billing_v2 with the required constraints

```bash
sudo docker run -d \
  --name billing_v2 \
  --memory=64m \
  -p 9090:80 \
  nginx:alpine
```

`-d` detaches. `--memory=64m` caps the container's cgroup memory at 64 megabytes. `-p 9090:80` maps host port 9090 (now free) to container port 80, where `nginx:alpine` listens by default.

Verify before moving on:

```bash
sudo docker ps --filter "name=billing_v2"
sudo docker inspect --format '{{ .HostConfig.Memory }}' billing_v2
# 67108864   (64 * 1024 * 1024 bytes)
```

## Step 3: Write the health-check script

```bash
sudo tee /home/ops-monitor/watch-billing.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
if [ "$(docker inspect -f '{{ .State.Running }}' billing_v2 2>/dev/null)" != "true" ]; then
  docker start billing_v2
fi
EOF

sudo chmod 755 /home/ops-monitor/watch-billing.sh
sudo chown ops-monitor:ops-monitor /home/ops-monitor/watch-billing.sh
```

`docker inspect -f '{{ .State.Running }}'` asks one precise question — is the container currently running — the same `--format` pattern used throughout this section. If the container isn't running (stopped, crashed, or simply absent from a fresh `docker ps`), `docker start` brings the *same* container back up rather than creating a new one, which is why `docker run` would be the wrong tool here — it would collide on the already-existing name.

`ops-monitor` needs Docker group membership for this to work non-interactively (already granted at bootstrap) — without it, `docker start` inside the cron job would fail with a permission error against the Docker socket, and that failure would be invisible unless you went looking for it in cron's mail or logs.

## Step 4: Schedule it in ops-monitor's crontab, every minute

```bash
sudo crontab -u ops-monitor -e
```

Add:

```cron
* * * * * bash /home/ops-monitor/watch-billing.sh
```

Five stars means "every minute of every hour of every day" — the correct cadence for a health check that needs to notice and react to a crash quickly. As always, `-u ops-monitor` is what makes this ops-monitor's crontab rather than root's own.

## Step 5: Prove the recovery mechanism actually works

Don't just trust that the cron line looks right — simulate the failure it's meant to catch:

```bash
sudo docker stop billing_v2
sleep 65
sudo docker ps --filter "name=billing_v2"
# should show billing_v2 back in the Up state within about a minute
```

If it doesn't come back, check that ops-monitor's crontab was saved correctly, that the script is executable, and that `sudo -u ops-monitor docker ps` doesn't fail with a permission-denied error against the Docker socket.

---

## Command Summary

```bash
sudo docker stop billing_v1
sudo docker rm billing_v1
sudo docker run -d --name billing_v2 --memory=64m -p 9090:80 nginx:alpine

sudo tee /home/ops-monitor/watch-billing.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
if [ "$(docker inspect -f '{{ .State.Running }}' billing_v2 2>/dev/null)" != "true" ]; then
  docker start billing_v2
fi
EOF
sudo chmod 755 /home/ops-monitor/watch-billing.sh
sudo chown ops-monitor:ops-monitor /home/ops-monitor/watch-billing.sh

sudo crontab -u ops-monitor -e
# add: * * * * * bash /home/ops-monitor/watch-billing.sh

sudo docker stop billing_v2
sleep 65
sudo docker ps --filter "name=billing_v2"
```

Once verified, run the local validation suite to pass the lab!
