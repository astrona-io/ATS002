# Question

Solve this question on: `terminal`

Logs on this host do not survive a reboot — `journalctl -b -1` shows
nothing, because the journal is stored only in `/run` (volatile). It is also
uncapped, which on a busy host risks filling `/var` over time.

Configure `systemd-journald` so that:

1. The journal is **persistent** — it is kept under `/var/log/journal/` and
   survives reboots (`Storage=persistent`, and the directory actually
   populated).
2. On-disk journal usage is **bounded to 200 MB or less** (`SystemMaxUse`).
3. The changes are **applied now**, not just written to the config file —
   after your change, `journalctl` reports a persistent store and
   `journalctl --disk-usage` shows a size within the cap.

Put the settings in `/etc/systemd/journald.conf` or a drop-in under
`/etc/systemd/journald.conf.d/`.
