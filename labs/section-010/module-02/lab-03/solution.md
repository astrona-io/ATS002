# Solution Walkthrough

## 1. Inspect all three ceilings

```bash
sysctl -n kernel.pid_max
# 4194304                       <- generous, not the problem

sudo -iu dataproc bash -c 'ulimit -u'
# 65536                         <- generous, not the problem

systemctl show data-ingest.service -p TasksMax --value
# 64                            <- THIS is the clamp
```

The unit caps its own cgroup at **64** processes+threads — far below what
the workload needs, and independent of the (already fine) system-wide pool
and per-user limit.

## 2. Confirm where it comes from

```bash
systemctl cat data-ingest.service | grep -i tasksmax
# TasksMax=64
```

It is set directly in the vendor unit.

## 3. Raise only `TasksMax=`, via an override

```bash
sudo systemctl edit data-ingest.service
```

```ini
[Service]
TasksMax=infinity
```

(A finite value such as `200000` is also acceptable and is the safer choice
in production — it stops one runaway unit from starving the whole box.)

## 4. Apply it to the running unit

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service

systemctl show data-ingest.service -p TasksMax --value       # infinity
cat /sys/fs/cgroup/system.slice/data-ingest.service/pids.max # max
```

`daemon-reload` updates the plan; the *running* cgroup's `pids.max` does not
change until the unit is restarted into a fresh cgroup — that is why both
commands are needed.

## 5. Verify you left the others alone

```bash
sysctl -n kernel.pid_max                 # still 4194304
sudo -iu dataproc bash -c 'ulimit -u'    # still 65536
```

Neither needed a change — the pool and the per-user limit were never the
constraint.
