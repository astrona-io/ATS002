# section-010 / module-06 / lab-06: Set the default boot target

QEMU VM for the LFCS course. The host boots into `graphical.target` but
should be `multi-user.target`. Use `systemctl set-default` and verify with
`systemctl get-default` and the `/etc/systemd/system/default.target`
symlink. Covers the "configure the system to boot into a specific target"
LFCS objective.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-06
```
