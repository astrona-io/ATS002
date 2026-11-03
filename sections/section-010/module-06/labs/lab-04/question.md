# Question

Solve this question on: `terminal`

Astronaut, the data pipeline on this machine is down. `ingest.service` will not run, and it restarted so fast that `systemd` gave up on it. Neither `ingest.service` nor the backend it depends on, `ingest-db.service`, is enabled for boot.

Investigate with `systemctl status ingest`, `systemctl status ingest-db`, `journalctl -xeu ingest` and `systemctl list-dependencies ingest`. Find the **root cause** (it is not in `ingest.service` itself), and repair the pipeline so that:

- `systemctl is-active ingest-db` and `systemctl is-active ingest` both report `active`
- `systemctl is-enabled ingest-db` and `systemctl is-enabled ingest` both report `enabled`
- the `ExecStart=` of `ingest-db.service` points at a file that exists and can be run
- `ingest.service` really runs: its `SubState` is `running` (not stuck restarting), its `Result` is `success`, and it keeps adding lines to `/var/lib/ingest/ingest.log`

You will need to clear the latched "start request repeated too quickly" state before `ingest` will start again.
