# Overview: PLAYGROUND — AppArmor Profile Enforcement

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- One Ubuntu 24.04 qemu VM reached with `astrona ssh astro-apparmor-mac-enforcement`.
  AppArmor is the kernel's active Linux Security Module on this image — this is
  a real enforcing MAC layer, not a simulation.
- `apparmor-utils` installed: `aa-status`, `aa-enforce`, `aa-complain`,
  `aa-logprof`, `apparmor_parser`.
- A demo service **`appservice`** (`/usr/sbin/appservice`, a systemd unit
  running as the `appservice` user) that appends a heartbeat line to
  `/srv/applogs/app.log` every 5 seconds.
- Its AppArmor profile `/etc/apparmor.d/usr.sbin.appservice`, loaded in
  **enforce** mode, is deliberately **too strict**: it only permits the old log
  path `/var/log/appservice/`, with no rule for `/srv/applogs/`. DAC
  permissions on `/srv/applogs` are already correct — only AppArmor is blocking
  the write, so a fresh `apparmor="DENIED"` audit record is always waiting in
  the kernel log.
- The Ubuntu local-override file `/etc/apparmor.d/local/usr.sbin.appservice`
  exists but is empty.
- `lsblk` shows `vda` (the ~15 GiB OS disk) and `vdb` (a ~366 KiB cloud-init
  disk). No extra attached disks.

SELinux is **not** here — this is an AppArmor kernel. Part II of the module is a
conceptual SELinux walkthrough for exactly that reason; those commands
(`getenforce`, `semanage`, `restorecon`) have nothing to run against on this
host.

## Things to try

- `sudo aa-status` — how many profiles, which are in enforce vs complain mode.
- `sudo journalctl -k | grep 'apparmor="DENIED"'` — find the live denial:
  read the `profile=`, `operation=`, `name=`, `denied_mask=` fields.
- `cat /etc/apparmor.d/usr.sbin.appservice` — spot that `/srv/applogs` appears
  nowhere.
- Fix it two ways and compare: append a rule to
  `/etc/apparmor.d/local/usr.sbin.appservice` by hand then
  `sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice`; or run
  `sudo aa-logprof` and let it propose the rule.
- Flip the profile with `sudo aa-complain /usr/sbin/appservice` then
  `sudo aa-enforce /usr/sbin/appservice` and watch `aa-status` and the log
  behaviour change.
- After a fix, `tail -f /srv/applogs/app.log` and confirm new heartbeat lines
  land.

## When you're done

```sh
astrona destroy apparmor-mac-enforcement
```

(`astrona destroy` takes the environment name — `apparmor-mac-enforcement` —
not the config path. The running machine is `astro-apparmor-mac-enforcement`.)
