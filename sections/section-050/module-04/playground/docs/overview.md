# Overview: APT Package Information Lookup Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-apt-package-research`.
- A few `python3-*` packages installed, so `apt list --installed` has something to match.
- The folder `/opt/course/apt-research`, owned by the `student` user, for saving what you find.
- The normal `apt`, `apt-cache` and `dpkg` tools. Every research command is read-only.

## Things to try

- Search with `apt search fail2ban` and compare it with `apt-cache search fail2ban`.
- Read a full description with `apt show nginx`, and the installed and candidate versions with `apt-cache policy nginx`.
- List installed packages by pattern with `apt list --installed 'python3-*'`, and read the details of one with `dpkg -s`.
- Save an output into `/opt/course/apt-research/` with a redirect, then read the file back.

## When you are done

```sh
astrona destroy apt-package-research
```

`astrona destroy` takes the playground's name, `apt-package-research`, not the folder path. The running machine is called `astro-apt-package-research`.
