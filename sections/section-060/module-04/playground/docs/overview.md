# Overview: DNF Package Information Lookup Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-dnf-package-research`.
- Docker with a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Inside it `rpm`, `dnf` and the RPM database are all real. Open a shell in it with `docker exec -it rpmbox bash`.
- The EPEL repository enabled inside `rpmbox`, and a fresh repository catalogue.
- A few `python3-*` packages installed.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Search with `dnf search fail2ban` and read a description with `dnf info nginx`.
- Find which package provides a file with `dnf provides /usr/sbin/ip` or `dnf provides '*/bin/ip'`.
- List installed packages by pattern with `dnf list installed 'python3-*'`.
- Read one package's details with `rpm -qi`.

## When you are done

```sh
astrona destroy dnf-package-research
```

`astrona destroy` takes the playground's name, `dnf-package-research`, not the folder path. The running machine is called `astro-dnf-package-research`.
