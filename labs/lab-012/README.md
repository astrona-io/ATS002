# lab-012: Process Limits — pid_max, ulimit, and systemd TasksMax

QEMU VM for the LFCS course — diagnosing and raising the three independent process/thread ceilings (`kernel.pid_max`, per-user `ulimit -u`, and a systemd unit's `TasksMax=`) behind a "cannot fork" incident.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-012
```
