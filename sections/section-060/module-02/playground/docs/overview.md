# Overview: RPM Database Rebuild Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-rpm-database-repair`.
- Docker with a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Inside it `rpm`, `dnf` and the RPM database are all real. Open a shell in it with `docker exec -it rpmbox bash`.
- `vim-enhanced`, `wget` and `tree` installed inside `rpmbox`, so the database holds real data.
- The database file `/var/lib/rpm/rpmdb.sqlite` inside `rpmbox`, deliberately damaged: part of it holds random bytes and the end is cut off. The installed programs themselves are untouched.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Run `rpm -qa` and `dnf check` inside `rpmbox` and read the errors.
- Make a copy of `/var/lib/rpm` before you change anything.
- Verify `/root/rpmdb-known-good.sha256` from `/root/rpmdb-known-good`, restore that saved database, then run `rpm --rebuilddb` and `dnf check`. Compare `rpm -qa | LC_ALL=C sort` with `/root/rpm-packages-before.txt`; every original record must survive.
- Run `rpm -V tree` to prove the files themselves were never harmed.

## When you are done

```sh
astrona destroy rpm-database-repair
```

`astrona destroy` takes the playground's name, `rpm-database-repair`, not the folder path. The running machine is called `astro-rpm-database-repair`.
