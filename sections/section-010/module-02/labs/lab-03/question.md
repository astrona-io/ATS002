# Question

Solve this question on: `terminal`

Astronaut, the `data-ingest.service` unit on this ship runs as the user `dataproc`. It hits a hard task ceiling long before CPU or memory are under any stress.

Three independent ceilings could be responsible: `kernel.pid_max`, the user's `ulimit -u` (`RLIMIT_NPROC`), and the unit's own `TasksMax=`. **Only one of them is the real limit here.** The other two are already generous.

1. Inspect all three:
   - `sysctl -n kernel.pid_max`
   - `sudo -iu dataproc bash -c 'ulimit -u'`
   - `systemctl show data-ingest.service -p TasksMax --value`
2. Find the one ceiling that caps the unit far below what a thread-heavy workload needs.
3. Raise **only that one**, with a systemd override, to `infinity` or at least `65536`. Then apply it to the running unit, so that `systemctl show data-ingest.service -p TasksMax --value` reports the new value.

Do **not** raise `kernel.pid_max` or `dataproc`'s `ulimit -u`. They are already fine. Adding a `kernel.pid_max` line to any sysctl file, or a new `nproc` line for `dataproc` under `/etc/security/limits.d/`, counts as a wrong diagnosis here.
