# Question

Solve this question on: `terminal`

Astronaut, `metricsd.service` fails every time it starts. It is enabled for boot, but right now it is not running: it is in the `failed` state.

The unit runs as its own non-root user and writes its data under `/var/lib/metricsd`. Find out why it fails with `systemctl status metricsd` and `journalctl -xeu metricsd`. Then repair it so that:

- `systemctl is-active metricsd` reports `active`
- `systemctl is-enabled metricsd` reports `enabled`
- the unit still runs as a **non-root** user (its `User=` is set, and it is not `root`)
- the daemon really runs: it adds a line to `/var/lib/metricsd/metrics.log` every few seconds, so the file keeps growing

Running the service as `root`, or disabling or masking the unit, does not count. Fix the access problem itself.
