# Question

Solve this question on: `terminal`

The data pipeline on this host is down. `ingest.service` will not run, and
it has been restarting so fast that systemd has given up on it. Neither
`ingest.service` nor its backend `ingest-db.service` is enabled for boot.

Investigate the failure — `systemctl status ingest`, `systemctl status
ingest-db`, `journalctl -xeu ingest`, `systemctl list-dependencies ingest` —
find the **root cause** (it is not in `ingest.service` itself), and repair
the pipeline so that:

- `systemctl is-active ingest-db` and `systemctl is-active ingest` both
  report `active`
- `systemctl is-enabled ingest-db` and `systemctl is-enabled ingest` both
  report `enabled`
- `ingest.service` is genuinely running (not stuck auto-restarting), and is
  appending to `/var/lib/ingest/ingest.log`

You will need to clear the latched "start request repeated too quickly"
state before `ingest` will start again.
