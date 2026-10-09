# Overview: process-limits playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh` once, and waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy`, and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine, your training ship. Open a terminal on it with `astrona ssh astro-process-limits-ceilings`.
- A user called **`dataproc`**, to try `ulimit -u` and files under `/etc/security/limits.d/` on.
- A demo service, **`data-ingest.service`**, running with `TasksMax=64`. This per-service cgroup cap is set low on purpose, so `systemctl show data-ingest.service -p TasksMax -p TasksCurrent` shows a ceiling that is neither `pid_max` nor `ulimit -u`.
- `lsblk` shows `vda` (about 15 GiB, the system disk) and `vdb` (about 366 KiB, the cloud-init disk with start-up settings). There are no extra disks.

## Things to try

- Compare `sysctl -n kernel.pid_max` with `ps -eLf | wc -l`: the size of the pool against the number of tasks running now.
- Run `ulimit -u`, then `sudo -u dataproc bash -c 'ulimit -u'`: the per-user cap, counted per real user.
- Run `systemctl show data-ingest.service -p TasksMax -p TasksCurrent`: the per-service cap.
- Raise each ceiling. Run `sudo sysctl -w kernel.pid_max=4194304`. Then run `sudo systemctl edit data-ingest.service`, set `TasksMax=200000` under `[Service]`, run `sudo systemctl daemon-reload` and `sudo systemctl restart data-ingest.service`, and check the value again.

## When you are done

```sh
astrona destroy process-limits-ceilings
```

`astrona destroy` takes the playground's name, `process-limits-ceilings`. The running machine itself is called `astro-process-limits-ceilings`, which is the name `astrona ssh` uses.
