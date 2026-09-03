# Solution Walkthrough

Follow these steps to diagnose and raise all three independent ceilings.

---

## Step 1: Confirm this is a fork/thread-creation ceiling, not memory or CPU pressure

```bash
free -m
top -bn1 | head -5
dmesg | tail -30 | grep -iE 'fork|cannot allocate|out of memory'
```

An idle-looking CPU/RAM combined with `fork`/`pthread_create` failures is the signature of a process/thread ceiling, not real resource exhaustion.

---

## Step 2: Read the current `kernel.pid_max` value

```bash
sysctl -n kernel.pid_max
cat /proc/sys/kernel/pid_max
```

You should see the legacy default, `32768`. Modern 64-bit kernels can support values up to `4194304` (2²²).

---

## Step 3: Raise `kernel.pid_max` live, then persist it

```bash
sudo sysctl -w kernel.pid_max=4194304
```

```bash
echo "kernel.pid_max = 4194304" | sudo tee /etc/sysctl.d/98-pid-max.conf
sudo sysctl --system
```

The live `sysctl -w` change alone would evaporate on reboot; the drop-in file under `/etc/sysctl.d/` combined with `sysctl --system` makes it both immediate and permanent.

---

## Step 4: Check the second ceiling — `ulimit -u` for the `dataproc` user

```bash
sudo -iu dataproc bash -c 'ulimit -u'
```

This should currently show a low value (well below what a thread-heavy workload needs). Raise it persistently by dropping a file under `/etc/security/limits.d/` — this is read by `pam_limits` at login/session-start time, so a *new* file overriding an existing low baseline needs to sort after it alphabetically to win:

```bash
sudo tee /etc/security/limits.d/50-dataproc.conf > /dev/null <<'EOF'
dataproc soft nproc 32768
dataproc hard nproc 65536
EOF
```

Confirm it applied to a fresh session for that user:

```bash
sudo -iu dataproc bash -c 'ulimit -u'
# 32768
```

`-iu dataproc` starts a full login session as `dataproc`, which is what actually triggers `pam_limits` to re-read the limits files — an already-open shell would not pick this up without a fresh login.

---

## Step 5: Check the third ceiling — `TasksMax=` on the systemd unit

```bash
systemctl show data-ingest.service --property=TasksMax,TasksCurrent
```

This unit was started with a low, explicit `TasksMax=`. Raise it with a systemd override:

```bash
sudo systemctl edit data-ingest.service
```

Add:

```ini
[Service]
TasksMax=infinity
```

Apply it to the running unit:

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
```

An override file alone does not retroactively apply to an already-running cgroup — `daemon-reload` plus a restart is required.

---

## Step 6: Verify all three

```bash
sysctl -n kernel.pid_max
# 4194304

cat /etc/sysctl.d/98-pid-max.conf
# kernel.pid_max = 4194304

sudo -iu dataproc bash -c 'ulimit -u'
# 32768

grep dataproc /etc/security/limits.d/50-dataproc.conf
# dataproc soft nproc 32768
# dataproc hard nproc 65536

systemctl show data-ingest.service --property=TasksMax
# TasksMax=infinity
```

---

## Command Summary

```bash
free -m
sysctl -n kernel.pid_max

sudo sysctl -w kernel.pid_max=4194304
echo "kernel.pid_max = 4194304" | sudo tee /etc/sysctl.d/98-pid-max.conf
sudo sysctl --system

sudo -iu dataproc bash -c 'ulimit -u'
sudo tee /etc/security/limits.d/50-dataproc.conf > /dev/null <<'EOF'
dataproc soft nproc 32768
dataproc hard nproc 65536
EOF

systemctl show data-ingest.service --property=TasksMax,TasksCurrent
sudo systemctl edit data-ingest.service
# [Service]
# TasksMax=infinity
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
```

Once verified, run the local validation suite to pass the lab!
