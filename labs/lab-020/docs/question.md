# Question

Solve this question on: `terminal`

A decommissioned container named `billing_v1` is still running and squatting on host port `9090` — the exact port its replacement needs.

1. Retire `billing_v1` completely (stop it and remove the container) so port `9090` is free.
2. Launch its replacement as a new detached container:
   - Name: `billing_v2`.
   - Image: `nginx:alpine`.
   - Memory limit: `64m` (64 megabytes).
   - TCP port map: `9090/host` => `80/container`.
3. The service account `ops-monitor` already exists with Docker access. Write a small script that checks whether `billing_v2` is running, and starts it back up if it isn't. Schedule that script in `ops-monitor`'s own per-user crontab to run **every minute**, so `billing_v2` automatically recovers on its own if it ever crashes or gets stopped.
