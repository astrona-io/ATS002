# Question

Solve this question on: `terminal`

The `credsync` daemon reads its API key from `/etc/credsync/api.key` on
every cycle. The key used to live under `/var/lib/credsync/`. Standard Unix
ownership and permissions on `/etc/credsync/api.key` are already correct for
the `credsync` user, but the daemon still cannot read it.

1. Check the mode of the `credsync` AppArmor profile with `aa-status`.
2. Find the exact denial in the kernel audit trail (`journalctl -k`,
   searching for `apparmor="DENIED"`). Note what `operation=`,
   `requested_mask=`, `denied_mask=`, and `name=` say — this is a **read**
   denial, not a write.
3. Inspect the profile at `/etc/apparmor.d/usr.sbin.credsync` and identify
   why `/etc/credsync/api.key` is not covered.
4. Add a rule permitting the daemon to **read** `/etc/credsync/api.key`
   (by hand in `/etc/apparmor.d/local/`, or via `aa-logprof`).
5. Reload the profile with `apparmor_parser -r`.
6. Confirm the profile is still in `enforce` mode (not switched to
   `complain`) and that the daemon is now reading the key with no further
   denials. The daemon writes `/run/credsync/ready` only while the read is
   succeeding.
