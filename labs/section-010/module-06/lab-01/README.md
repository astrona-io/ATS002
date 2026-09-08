# section-010 / module-06 / lab-01: Service won't start — bad ExecStart path

QEMU VM for the LFCS course. `reportd.service` fails at start with
`status=203/EXEC` because its `ExecStart=` names a path that does not exist;
the real binary is elsewhere on disk. Diagnose with `systemctl status` /
`journalctl -xeu`, correct the unit, and confirm it is active **and** enabled
and genuinely running its work loop.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-06/lab-01
```
