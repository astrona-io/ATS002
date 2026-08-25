# Question

Solve this question on: `terminal` (playing the role of an admin on `web-srv1`)

Two independent services on this host are being blocked by AppArmor, each in a different way. Standard Unix ownership and permissions are already correct everywhere involved — both failures are AppArmor path-rule gaps, not DAC problems.

## Part 1 — logshipper (write denial)

`logshipper` has been reconfigured to write its logs to `/srv/shiplogs` instead of its original directory, and every write attempt is failing.

1. Confirm AppArmor is active and check the mode of the `logshipper` profile with `aa-status`.
2. Find the denial in the kernel audit trail (`dmesg` or `journalctl -k`, searching for `apparmor="DENIED"`).
3. Add a rule permitting `logshipper` to read and write under `/srv/shiplogs` (hand-edit the profile, its local override, or use `aa-logprof`).
4. Reload the profile with `apparmor_parser -r` and confirm it is genuinely back in `enforce` mode.
5. Confirm `logshipper` is now writing to `/srv/shiplogs/ship.log` with no further denials.

## Part 2 — metrics-agent (read denial)

`metrics-agent` has been reconfigured to read its remote credentials from `/etc/metrics-agent/remote.conf` instead of its original config file, and it cannot read the new file at all.

1. Confirm AppArmor is active and check the mode of the `metrics-agent` profile with `aa-status`.
2. Find the denial in the kernel audit trail for the read attempt against `/etc/metrics-agent/remote.conf`.
3. Add a rule permitting `metrics-agent` to read `/etc/metrics-agent/remote.conf` (hand-edit the profile, its local override, or use `aa-logprof`).
4. Reload the profile with `apparmor_parser -r` and confirm it is genuinely back in `enforce` mode.
5. Confirm `metrics-agent` is now successfully reading the token from `/etc/metrics-agent/remote.conf` and recording it in `/var/lib/metrics-agent/status`, with no further denials.

Neither profile should be left in `complain` mode when you're done — both denials must be closed with the profile genuinely enforcing.
