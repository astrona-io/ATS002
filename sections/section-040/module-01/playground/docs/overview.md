# Overview: AppArmor Profile Enforcement Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-apparmor-mac-enforcement`. AppArmor is the kernel's active security module on this image: a real, enforcing Mandatory Access Control (MAC) layer, not a simulation. Picture it as the ship's security chief, a second check behind the normal file permissions.
- The `apparmor-utils` tools: `aa-status`, `aa-enforce`, `aa-complain`, `aa-logprof` and `apparmor_parser`.
- A demo service, **`appservice`** (`/usr/sbin/appservice`), run by `systemd` as the `appservice` user. It adds a heartbeat line to `/srv/applogs/app.log` every 5 seconds.
- Its AppArmor profile, `/etc/apparmor.d/usr.sbin.appservice`, loaded in **enforce** mode. The profile is **too strict** on purpose: it only allows the old log folder `/var/log/appservice/` and has no rule for `/srv/applogs/`. The normal file permissions on `/srv/applogs` are already correct, so only AppArmor blocks the write, and a fresh `apparmor="DENIED"` record is always waiting in the kernel log.
- The Ubuntu local override file `/etc/apparmor.d/local/usr.sbin.appservice`. It exists and holds only one comment line.
- `lsblk` shows `vda` (the operating system disk, about 15 GiB) and `vdb` (a small cloud-init disk of about 366 KiB). There are no extra disks.

SELinux is **not** here: this is an AppArmor kernel. That is why the module teaches SELinux as a worked walkthrough. Its commands (`getenforce`, `semanage`, `restorecon`) have nothing to run against on this machine.

## Things to try

- Run `sudo aa-status` to see how many profiles are loaded and which are in enforce or complain mode.
- Run `sudo journalctl -k | grep 'apparmor="DENIED"'` to find the live denial. Read its `profile=`, `operation=`, `name=` and `denied_mask=` fields.
- Run `cat /etc/apparmor.d/usr.sbin.appservice` and notice that `/srv/applogs` appears nowhere.
- Fix it in two ways and compare. First, add the missing rules to `/etc/apparmor.d/local/usr.sbin.appservice` in an editor, then run `sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.appservice`. Second, start a fresh playground, run `sudo aa-logprof` and let it suggest the rule.
- Switch the profile with `sudo aa-complain /usr/sbin/appservice` and then `sudo aa-enforce /usr/sbin/appservice`, and watch how `aa-status` and the log change.
- After a fix, run `tail -f /srv/applogs/app.log` and check that new heartbeat lines arrive.

## When you are done

```sh
astrona destroy apparmor-mac-enforcement
```

`astrona destroy` takes the playground's name, `apparmor-mac-enforcement`, not the folder path. The running machine is called `astro-apparmor-mac-enforcement`.
