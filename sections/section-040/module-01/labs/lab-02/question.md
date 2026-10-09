# Question

Solve this question on: `terminal`

Astronaut, the `credsync` daemon on this ship reads its API key from `/etc/credsync/api.key` on every cycle. The key used to live under `/var/lib/credsync/`. The normal Unix owner and permissions on `/etc/credsync/api.key` are already correct for the `credsync` user, but the daemon still cannot read the key. This time AppArmor blocks a **read**, not a write.

Repair it so that all of the following are true:

1. The daemon can read `/etc/credsync/api.key` again. You can see this from the file `/run/credsync/ready`: the daemon writes it fresh every cycle, but only while the read works.
2. No new `apparmor="DENIED"` entries for `credsync` appear in the kernel log.
3. The AppArmor profile for `/usr/sbin/credsync` is loaded in **enforce** mode. A profile left in complain mode fails the task.
4. `credsync.service` is running.

The profile file is `/etc/apparmor.d/usr.sbin.credsync`, and its local override is `/etc/apparmor.d/local/usr.sbin.credsync`. You may add the rule by hand or with `aa-logprof`. The daemon only reads the key, so a read rule is all it needs.

The grader checks the live machine: the profile's mode in `aa-status`, the service state, that `/run/credsync/ready` exists and was updated in the last few seconds, and the recent kernel log.
