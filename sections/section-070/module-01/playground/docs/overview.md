# Overview: Zypper Basic Package Operations Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-zypper-everyday`.
- Docker with a long-lived openSUSE Leap 15.6 container named `zypperbox`. Inside it `zypper`, the RPM database and the openSUSE repositories are all real. Open a shell in it with `docker exec -it zypperbox bash`.
- The community `network:utilities` repository added inside `zypperbox`.
- `telnet-server` installed. `fail2ban` not installed.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Run `zypper refresh`, then compare `zypper list-updates` with `zypper list-patches`.
- Apply only the patches with `zypper patch`, or every newer version with `zypper update`.
- Install `fail2ban` with `zypper install fail2ban`.
- Remove `telnet-server` with `zypper remove`, then read `zypper history` or `/var/log/zypp/history`.

## When you are done

```sh
astrona destroy zypper-everyday
```

`astrona destroy` takes the playground's name, `zypper-everyday`, not the folder path. The running machine is called `astro-zypper-everyday`.
