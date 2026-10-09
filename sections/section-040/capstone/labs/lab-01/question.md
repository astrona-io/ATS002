# Question

Solve this question on: `terminal`

Astronaut, two separate services on this ship are blocked by AppArmor, each in a different way. The normal Unix owner and permissions are already correct everywhere. Both failures are missing path rules in AppArmor profiles, not permission problems.

## Service 1: logshipper (write denial)

`logshipper` has been set up to write its log to `/srv/shiplogs` instead of its old folder, and every write fails.

Repair it so that:

1. The AppArmor profile for `/usr/sbin/logshipper` contains a rule that names `/srv/shiplogs` and lets the service read and write its log there. Put it in `/etc/apparmor.d/usr.sbin.logshipper` or in its local override `/etc/apparmor.d/local/usr.sbin.logshipper`, by hand or with `aa-logprof`.
2. `/srv/shiplogs/ship.log` keeps growing on its own, and no new `apparmor="DENIED"` entries for `shiplogs` appear in the kernel log.
3. The profile is loaded in **enforce** mode, and `logshipper.service` is running.

## Service 2: metrics-agent (read denial)

`metrics-agent` has been set up to read its remote credentials from `/etc/metrics-agent/remote.conf` instead of its old configuration file, and it cannot read the new file at all.

Repair it so that:

1. The AppArmor profile for `/usr/sbin/metrics-agent` contains a rule that names the exact path `/etc/metrics-agent/remote.conf` and lets the service read it. Put it in `/etc/apparmor.d/usr.sbin.metrics-agent` or in its local override `/etc/apparmor.d/local/usr.sbin.metrics-agent`, by hand or with `aa-logprof`.
2. `metrics-agent` reads the token from `/etc/metrics-agent/remote.conf` and records it in `/var/lib/metrics-agent/status`, which keeps growing, and no new `apparmor="DENIED"` entries for `remote.conf` appear in the kernel log.
3. The profile is loaded in **enforce** mode, and `metrics-agent.service` is running.

Neither profile may be left in complain mode. Both denials must be closed with the profile really enforcing.

The grader checks the live machine: each profile's mode in `aa-status`, each service's state, the rules in the profile files, the growth of `/srv/shiplogs/ship.log` and `/var/lib/metrics-agent/status` over a few seconds, the token in the status file, and the recent kernel log.
