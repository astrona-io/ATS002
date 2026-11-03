# Question

Solve this question on: `terminal`

Astronaut, the `data-ingest.service` batch job on this ship runs as the user `dataproc`. It is failing again with `fork: retry: Resource temporarily unavailable`, even though CPU and memory are idle.

Three independent ceilings can cause this: `kernel.pid_max`, the user's `ulimit -u` (`RLIMIT_NPROC`), and the unit's `TasksMax=`. **On this machine, only one of them is the real limit.** The other two are already set generously.

1. Inspect all three:
   - `sysctl -n kernel.pid_max`
   - `sudo -iu dataproc bash -c 'ulimit -u'`
   - `systemctl show data-ingest.service -p TasksMax --value`
2. Find the one ceiling that holds the workload below what it needs (roughly tens of thousands of tasks).
3. Raise **only that one** to at least `32768`, persistently, in the standard place for that kind of ceiling: a file under `/etc/sysctl.d/` for a kernel parameter, a drop-in file under `/etc/security/limits.d/` for a user limit, or a systemd override for a unit. A fresh login session must show the new value.

Do **not** change the other two. They are already fine. Adding a `kernel.pid_max` line to any sysctl file, or a `TasksMax=` override, counts as a wrong diagnosis here.
