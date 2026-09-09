# section-020 / module-03 / lab-01: systemd Timers

QEMU VM for the LFCS course. Create a `.service` + `.timer` pair that runs a
maintenance script `OnCalendar=Mon,Thu 11:15` with `Persistent=true`, enable
and start the timer; then convert an existing `/etc/cron.d/` job to an
equivalent 6-hourly timer and remove the cron line so it doesn't fire twice.
Verify with `systemctl list-timers`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-03/labs/lab-01
```
