# Question

Solve this question on: `terminal` (playing the role of an admin on `web-srv1`)

The `appservice` daemon has been reconfigured to write its heartbeat logs to `/srv/applogs` instead of its original location. Standard Unix ownership and permissions on `/srv/applogs` are already correct for the service's user, but the service still fails to write there.

1. Confirm AppArmor is active and check the mode of the `appservice` profile with `aa-status`.
2. Find the exact denial in the kernel audit trail (`dmesg` or `journalctl -k`, searching for `apparmor="DENIED"`).
3. Inspect the current profile at `/etc/apparmor.d/usr.sbin.appservice` and identify why `/srv/applogs` isn't covered.
4. Add a rule permitting the service to read and write under `/srv/applogs` — either by hand-editing the profile (or its local override under `/etc/apparmor.d/local/`) or by using the `aa-logprof` workflow.
5. Reload the profile with `apparmor_parser -r` so the running kernel picks up the change.
6. Confirm the profile is genuinely back in `enforce` mode (not left in `complain` mode as a shortcut) and that the service is now writing to `/srv/applogs/app.log` with no further denials.
