# Question

Solve this question on: `terminal`

The `data-ingest.service` batch job on this system, run by the `dataproc` user, spawns a very large number of worker threads to parallelize a nightly ingest run. For the last several nights the job has failed partway through with errors like `fork: retry: Resource temporarily unavailable` and `pthread_create failed`, even though CPU and memory are otherwise idle. There isn't just one ceiling that could cause this — there are three, and you need to check and, where necessary, raise all of them:

1.  Raise the kernel-wide `kernel.pid_max` to at least `1048576`, both live and persistently (a config file under `/etc/sysctl.d/`).
2.  Raise the `dataproc` user's max-processes ceiling (`ulimit -u` / `RLIMIT_NPROC`) to at least `32768`, persistently, via a drop-in file under `/etc/security/limits.d/`.
3.  Raise the `data-ingest.service` systemd unit's `TasksMax=` so it no longer caps the workload below what it needs — set it to `infinity` (or at least `65536`) via a systemd override, then apply the change to the running unit (`daemon-reload` + restart).
