# Overview — process-limits playground

A **playground**, not a lab: boots, runs `bootstrap/prepare.sh`, waits. No task, no `astrona submit`, no pass/fail.

## What's in the box

- One Ubuntu 24.04 qemu VM, reached with `astrona ssh astro-process-limits-ceilings`.
- A **`dataproc`** user — a subject for `ulimit -u` and `/etc/security/limits.d/`.
- A demo service **`data-ingest.service`** running with `TasksMax=64` — a deliberately low per-unit cgroup cap, so `systemctl show data-ingest.service -p TasksMax -p TasksCurrent` shows a ceiling that is neither `pid_max` nor `ulimit`.
- `lsblk` shows `vda` (~15 GiB OS disk) and `vdb` (~366 KiB cloud-init disk). No extra disks.

## Things to try

- `sysctl -n kernel.pid_max` and `ps -eLf | wc -l` — pool size vs current task count.
- `ulimit -u` then `sudo -u dataproc bash -c 'ulimit -u'` — the per-real-UID cap.
- `systemctl show data-ingest.service -p TasksMax -p TasksCurrent` — the per-unit cap.
- Raise each: `sudo sysctl -w kernel.pid_max=4194304`; `sudo systemctl edit data-ingest.service` (set `TasksMax=200000`), `daemon-reload`, `restart`, re-check.

## When you're done

```sh
astrona destroy process-limits-ceilings
```
