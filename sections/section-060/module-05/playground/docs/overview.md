# Overview: DNF Package Groups Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-dnf-package-groups`.
- Docker with a long-lived, privileged Rocky Linux 9 container named `rpmbox`. Inside it `rpm`, `dnf` and the RPM database are all real. Open a shell in it with `docker exec -it rpmbox bash`.
- `automake` installed on its own, before any group was touched. It is also a member of the `Development Tools` group.
- The `Development Tools` group itself not installed.

The host machine itself runs Ubuntu 24.04, which has no `rpm`-family tools of its own. Run every package command inside the container, not on the host. If Docker refuses with a permission error, put `sudo` in front of `docker`.

## Things to try

- List the groups with `dnf group list` and read a group with `dnf group info "Development Tools"`.
- Install the group with `dnf group install "Development Tools"`, then run `dnf group list --installed`.
- Remove the group with `dnf group remove "Development Tools"` and check whether `automake` is still there with `rpm -q automake`.

## When you are done

```sh
astrona destroy dnf-package-groups
```

`astrona destroy` takes the playground's name, `dnf-package-groups`, not the folder path. The running machine is called `astro-dnf-package-groups`.
