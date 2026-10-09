# Question

Solve this question on: `terminal`

Astronaut, the logs on this machine do not survive a reboot: the journal is kept only in memory, under `/run`, so `journalctl -b -1` shows nothing. The journal also has no size limit of its own, and on a busy machine it could slowly fill `/var`.

Configure `systemd-journald` so that:

1. The journal is **persistent**: `Storage=persistent` is set, and the journal is really kept under `/var/log/journal/`, with journal files in that folder.
2. The journal's disk use is **capped at 200 MB or less** with `SystemMaxUse=`.
3. The changes are **applied now**, not only written to a file: `journald` is writing journal files under `/var/log/journal/`, and `journalctl --disk-usage` reports the journal's size.

Put the settings in `/etc/systemd/journald.conf` or in a drop-in file under `/etc/systemd/journald.conf.d/` (a file ending in `.conf`).
