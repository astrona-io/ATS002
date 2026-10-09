# Solution Walkthrough

The skill here is diagnosis: read all three ceilings, find the one that is really too low, fix it on the running service, and change nothing else.

## 1. Inspect all three ceilings

```bash
sysctl -n kernel.pid_max
# 4194304                       <- generous, not the problem

sudo -iu dataproc bash -c 'ulimit -u'
# 65536                         <- generous, not the problem

systemctl show data-ingest.service -p TasksMax --value
# 64                            <- THIS is the clamp
```

The unit caps its own cgroup at **64** processes and threads. That is far below what the workload needs, and it does not depend on the system-wide pool or the per-user limit, which are both fine.

## 2. Confirm where it comes from

```bash
systemctl cat data-ingest.service | grep -i tasksmax
# TasksMax=64
```

It is set directly in the unit file.

## 3. Raise only `TasksMax=`, with an override

`systemctl edit` opens an editor on a new drop-in file for the unit:

```bash
sudo systemctl edit data-ingest.service
```

Add these lines, then save and close the editor:

```ini
[Service]
TasksMax=infinity
```

A finite value such as `200000` also passes. On a real server it is the safer choice, because it stops one runaway unit from using up the whole machine's PID space.

## 4. Apply it to the running unit

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service

systemctl show data-ingest.service -p TasksMax --value       # infinity
cat /sys/fs/cgroup/system.slice/data-ingest.service/pids.max # max
```

`daemon-reload` updates systemd's plan. The restart starts the unit in a fresh cgroup, so the running cgroup's `pids.max` surely carries the new limit. That is why you run both commands.

## 5. Verify you left the others alone

```bash
sysctl -n kernel.pid_max                 # still 4194304
sudo -iu dataproc bash -c 'ulimit -u'    # still 65536
```

Neither needed a change. The pool and the per-user limit were never the problem.

## 6. Send it for grading

From your own computer, run:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-03
```

If the check fails, its message says which ceiling is wrong. A message about `kernel.pid_max` or `nproc` means you changed a ceiling that was never the problem: remove that change and submit again.
