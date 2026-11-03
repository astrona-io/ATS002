# Overview: SELinux Commands Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail.

## What's in the box

- One Ubuntu 24.04 `qemu` virtual machine. Reach it with `astrona ssh astro-selinux-commands-bay`.
- **SELinux is not active on this ship.** Ubuntu uses AppArmor. The SELinux commands in the module (`semanage`, `restorecon`, `setsebool`) are for a RHEL-family system, so you write them down here and do not run them.
- A folder `/srv/web` with `index.html` and `images/logo.txt`. These are the real paths the module's examples name.
- An empty file `/root/selinux-notes.sh` for your practice command sequences.

## Things to try

- Write the persistent file-label sequence for `/srv/web` into `/root/selinux-notes.sh`, one command per line.
- Add the boolean and the port commands, then check the file with `bash -n /root/selinux-notes.sh`. A silent result means the shell syntax is fine. It does not prove the SELinux commands are right.
- Run `ls -l /srv/web` and compare it with what `ls -Z` would add on a RHEL-family system: a label column.

## When you're done

```sh
astrona destroy selinux-commands-bay
```

`astrona destroy` takes the playground's name, not the folder path.
