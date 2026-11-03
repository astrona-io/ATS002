# Overview: dpkg Low-Level Package Management Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-dpkg-low-level`.
- A `logtail-utils` `.deb` file (version 2.3.1) in `/home/candidate/downloads/`. No repository publishes it, and it is not installed.
- The `cowsay` package left in the half-configured state, so `dpkg -l` shows it with the status code `iF`.
- The normal `dpkg`, `dpkg-deb` and `dpkg-query` tools of Ubuntu 24.04.

## Things to try

- Read the file without installing it: `dpkg-deb --info` and `dpkg-deb --contents` on the `.deb`.
- Install it with `sudo dpkg -i`, then run `dpkg -L logtail-utils`, `dpkg -S /usr/bin/logtail` and `dpkg -s logtail-utils`.
- Run `dpkg -l | grep cowsay` and read the status code, then recover it with `sudo dpkg --configure -a`.
- Remove `logtail-utils` with `sudo dpkg -r`, then purge it with `sudo dpkg -P`, and watch the `dpkg -l` status code change.

## When you are done

```sh
astrona destroy dpkg-low-level
```

`astrona destroy` takes the playground's name, `dpkg-low-level`, not the folder path. The running machine is called `astro-dpkg-low-level`.
