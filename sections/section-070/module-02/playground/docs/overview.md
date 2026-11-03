# Overview: Zypper Package Information Lookup Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-zypper-package-research`.
- Docker with a long-lived openSUSE Leap 15.6 container named `zypperbox`. Inside it `zypper`, the RPM database and the openSUSE repositories are all real. Open a shell in it with `docker exec -it zypperbox bash`.
- A fresh repository catalogue inside `zypperbox`.
- `python3-base` and `python3-pip` installed.
- An empty folder `/root/answers` inside the container for saving what you find.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Search with `zypper search fail2ban`, and read a package with `zypper info nginx`.
- Find the package that owns a file with `zypper what-provides /usr/sbin/ip`.
- List installed packages with `zypper search --installed-only python3`.

## When you are done

```sh
astrona destroy zypper-package-research
```

`astrona destroy` takes the playground's name, `zypper-package-research`, not the folder path. The running machine is called `astro-zypper-package-research`.
