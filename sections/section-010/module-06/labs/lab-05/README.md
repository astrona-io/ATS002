# section-010 / module-06 / lab-05: Configure journald — persistent + bounded

QEMU VM for the LFCS course. The journal is volatile (lost on reboot) and
uncapped. Configure `systemd-journald` for persistent storage under
`/var/log/journal/` and a `SystemMaxUse` ceiling of 200 MB, then apply it
(restart journald) and verify with `journalctl --header` / `--disk-usage`.
Covers the "manage and configure system logging" LFCS objective.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-05
```
