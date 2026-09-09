# section-010 / module-02 / lab-03: Process limits — diagnose the single clamp (TasksMax=)

QEMU VM for the LFCS course. Diagnosis variant: `kernel.pid_max` and the
`dataproc` user's `ulimit -u` are already generous — only
`data-ingest.service`'s own `TasksMax=64` cgroup cap is clamping. Inspect
all three, identify the one real limit, raise **only** the unit override,
and apply it live with `daemon-reload` + `restart`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-03
```
