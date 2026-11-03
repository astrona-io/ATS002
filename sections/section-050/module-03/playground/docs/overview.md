# Overview: APT Basic Package Operations Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-apt-basic-operations`.
- The `ftp` client installed, with a tracked configuration file `/etc/ftp.conf`, so `apt remove ftp` leaves that file behind and `apt purge ftp` deletes it.
- `fail2ban` not installed.
- The normal `apt`, `apt-get`, `apt-cache` and `dpkg` tools. The machine reaches the Ubuntu repositories, so `apt update` and `apt install` work for real.

## Things to try

- Run `sudo apt update`, then `apt list --upgradable`, and compare it with what `sudo apt upgrade` does.
- Install `fail2ban` and read the list of extra packages `apt` adds in the same transaction.
- Run `sudo apt remove ftp`, then `dpkg -l | grep ftp` and `ls /etc/ftp.conf`. Now run `sudo apt purge ftp` and look again.
- Run `sudo apt autoremove --dry-run` first, then without `--dry-run`.

## When you are done

```sh
astrona destroy apt-basic-operations
```

`astrona destroy` takes the playground's name, `apt-basic-operations`, not the folder path. The running machine is called `astro-apt-basic-operations`.
