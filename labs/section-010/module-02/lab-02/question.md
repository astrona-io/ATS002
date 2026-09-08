# Question

Solve this question on: `terminal`

The `data-ingest.service` batch job (run by the `dataproc` user) is failing
with `fork: retry: Resource temporarily unavailable` again, even though CPU
and memory are idle.

There are three independent ceilings that can cause this — `kernel.pid_max`,
the user's `ulimit -u` / `RLIMIT_NPROC`, and the unit's `TasksMax=`. **On
this host, only one of them is actually the limit.** The other two are
already set generously.

1. Inspect all three:
   - `sysctl -n kernel.pid_max`
   - `sudo -iu dataproc bash -c 'ulimit -u'`
   - `systemctl show data-ingest.service -p TasksMax --value`
2. Identify which single ceiling is clamping the workload below what it
   needs (roughly tens of thousands of tasks).
3. Raise **only that one**, persistently (in the correct file family for
   that ceiling), to at least `32768`.

Do **not** change the other two — they are already fine, and adding a
redundant `pid_max` sysctl drop-in or a `TasksMax=` override counts as a
misdiagnosis here.
