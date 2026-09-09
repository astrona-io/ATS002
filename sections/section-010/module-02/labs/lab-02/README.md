# section-010 / module-02 / lab-02: Process limits — diagnose the single clamp (ulimit -u)

QEMU VM for the LFCS course. Diagnosis variant of the three-ceilings lab:
`kernel.pid_max` and the unit's `TasksMax=` are already generous — only the
`dataproc` user's `RLIMIT_NPROC` (`ulimit -u`) is clamped. The student must
inspect all three, identify the one real limit, and raise **only** that one,
persistently, without reflexively bumping the other two.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-02
```
