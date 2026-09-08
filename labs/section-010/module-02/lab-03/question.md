# Question

Solve this question on: `terminal`

`data-ingest.service` (run by the `dataproc` user) hits a hard task ceiling
well before CPU or memory are stressed.

Three independent ceilings could be responsible — `kernel.pid_max`, the
user's `ulimit -u` / `RLIMIT_NPROC`, and the unit's own `TasksMax=`. **Only
one of them is the actual limit here.** The other two are already generous.

1. Inspect all three:
   - `sysctl -n kernel.pid_max`
   - `sudo -iu dataproc bash -c 'ulimit -u'`
   - `systemctl show data-ingest.service -p TasksMax --value`
2. Identify the single ceiling that is capping the unit far below what a
   thread-heavy workload needs.
3. Raise **only that one** — via a systemd override — to `infinity` (or at
   least `65536`), then apply it to the running unit (`daemon-reload` +
   `restart`).

Do **not** raise `kernel.pid_max` or `dataproc`'s `ulimit -u` — they are
already fine, and touching them here is a misdiagnosis.
