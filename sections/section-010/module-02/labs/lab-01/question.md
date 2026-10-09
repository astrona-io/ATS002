# Question

Solve this question on: `terminal`

Astronaut, the `data-ingest.service` batch job on this ship runs as the user `dataproc`. It starts a very large number of worker threads to split up a nightly ingest run. For several nights the job has failed partway through, with errors like `fork: retry: Resource temporarily unavailable` and `pthread_create failed`, even though CPU and memory are mostly idle.

More than one ceiling can cause this. On this machine, all three are too low. Raise each of them:

1. Raise the kernel parameter `kernel.pid_max` to at least `1048576`, both live and persistently. For the persistent part, add your own configuration file under `/etc/sysctl.d/` (or a line in `/etc/sysctl.conf`). A file that already exists there sets a low value; do not rely on editing that file.
2. Raise the `dataproc` user's maximum number of processes (`ulimit -u`, also called `RLIMIT_NPROC`) to at least `32768`, persistently, with a drop-in file under `/etc/security/limits.d/`. A fresh login session of `dataproc` must show the new limit.
3. Raise the `TasksMax=` of the systemd unit `data-ingest.service` to `infinity` or at least `65536`, with a systemd override. Make sure systemd uses the new value for the unit (`systemctl show data-ingest.service -p TasksMax` must report it).
