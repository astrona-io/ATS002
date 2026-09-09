# Question

Solve this question on: `terminal`

The `reportd.service` unit on this host will not start. It is enabled for
boot but currently inactive/failed.

Diagnose why it fails to start using `systemctl status reportd` and
`journalctl -xeu reportd`, then repair it so that:

- `systemctl is-active reportd` reports `active`
- `systemctl is-enabled reportd` reports `enabled`
- the daemon is genuinely running its work loop (it writes to
  `/var/lib/reportd/heartbeat.log` every few seconds)

Do not disable, mask, or replace the service with a stub. Fix the actual
cause. The real daemon binary is present on the system — find where — and
make the unit point at it.
