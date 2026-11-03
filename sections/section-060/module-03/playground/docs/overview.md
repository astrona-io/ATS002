# Overview: DNF Basic Package Operations Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-dnf-everyday`.
- Docker with a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Inside it `rpm`, `dnf` and the RPM database are all real. Open a shell in it with `docker exec -it rpmbox bash`.
- The EPEL repository enabled inside `rpmbox`.
- `telnet` installed. `fail2ban` and `mtr` not installed.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Run `dnf check-update` and read the list, then `dnf upgrade` to apply it.
- Install `fail2ban` and `mtr` in one command, then run `dnf history` and `dnf history info <ID>` for that transaction.
- Undo the transaction with `dnf history undo <ID>`.
- Remove `telnet` with `dnf remove telnet`, then run `dnf autoremove`.

## When you are done

```sh
astrona destroy dnf-everyday
```

`astrona destroy` takes the playground's name, `dnf-everyday`, not the folder path. The running machine is called `astro-dnf-everyday`.
