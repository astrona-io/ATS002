# Question

Solve this question on: `terminal`

`metricsd.service` fails every time it starts. It is enabled for boot but
inactive/failed right now.

The unit runs as a dedicated non-root user and writes its data under
`/var/lib/metricsd`. Diagnose the failure with `systemctl status metricsd`
and `journalctl -xeu metricsd`, then repair it so that:

- `systemctl is-active metricsd` reports `active`
- `systemctl is-enabled metricsd` reports `enabled`
- the daemon is genuinely running (it appends to
  `/var/lib/metricsd/metrics.log` every few seconds)

The service must still run as a **non-root** user. Fixing this by changing
`ExecStart` to run as `root`, or by disabling/masking the unit, does not
count — fix the underlying access problem.
