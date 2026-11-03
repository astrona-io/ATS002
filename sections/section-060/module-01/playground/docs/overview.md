# Overview: RPM Low-Level Package Management Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-rpm-low-level`.
- Docker with a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Inside it `rpm`, `dnf` and the RPM database are all real. Open a shell in it with `docker exec -it rpmbox bash`.
- A small internal package, `logship-agent` version `2.1.0-1`, built inside `rpmbox`. The file is `/home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm` inside the container, and the package is not installed yet.
- The `rpmbuild` tools, which built it.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- Read the file without installing it: `rpm -qip`, `rpm -qlp` and `rpm -qRp` on the `.rpm`.
- Install it with `rpm -ivh`, then run `rpm -ql logship-agent`, `rpm -qf /usr/bin/logship-agent` and `rpm -qc logship-agent`.
- Check its files with `rpm -V logship-agent`, change `/etc/logship-agent/agent.conf`, and run `rpm -V` again.
- Check the whole system with `rpm -Va | head`.

## When you are done

```sh
astrona destroy rpm-low-level
```

`astrona destroy` takes the playground's name, `rpm-low-level`, not the folder path. The running machine is called `astro-rpm-low-level`.
