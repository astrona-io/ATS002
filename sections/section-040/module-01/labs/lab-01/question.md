# Question

Solve this question on: `terminal`

Astronaut, the `appservice` daemon on this ship has been set up to write its heartbeat log to `/srv/applogs` instead of its old folder. The normal Unix owner and permissions on `/srv/applogs` are already correct for the service's user, but the service still cannot write there. The AppArmor security chief is blocking it.

Repair it so that all of the following are true:

1. The AppArmor profile for `/usr/sbin/appservice` contains a rule that names `/srv/applogs` and lets the service read and write its log there. Put the rule in the main profile `/etc/apparmor.d/usr.sbin.appservice` or in its local override `/etc/apparmor.d/local/usr.sbin.appservice`, by hand or with `aa-logprof`.
2. The running kernel uses the changed profile, so the service writes again: `/srv/applogs/app.log` keeps growing on its own.
3. No new `apparmor="DENIED"` entries for `/srv/applogs` appear in the kernel log.
4. The profile is loaded in **enforce** mode. A profile left in complain mode fails the task.
5. `appservice.service` is running.

The owner and permissions of `/srv/applogs` are already correct, so there is nothing to change there.

The grader checks the live machine: the profile's mode in `aa-status`, the rule in the profile files, the service state, the size of `/srv/applogs/app.log` over a few seconds, and the recent kernel log.
