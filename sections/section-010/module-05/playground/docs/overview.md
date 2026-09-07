# Overview — strace process-forensics playground

A **playground**, not a lab: boots, runs `bootstrap/prepare.sh`, waits. No task, no `astrona submit`, no pass/fail.

## What's in the box

- One Ubuntu 24.04 qemu VM, reached with `astrona ssh astro-strace-process-forensics`.
- `strace` and `procps` (`pgrep`, `ps`).
- Three background services — **`collector1`, `collector2`, `collector3`** (`/usr/local/bin/collectorN`, each a systemd unit). All three loop on `sleep`; **`collector2` additionally makes a `kill()` syscall every ~10 s** (it sends itself `SIGCONT`), so `strace -e trace=kill` has something real to catch.
- `kernel.yama.ptrace_scope` is at its default (`1`), so attaching to these processes needs `sudo`.
- `lsblk` shows `vda` (~15 GiB OS disk) and `vdb` (~366 KiB cloud-init disk). No extra disks.

## Things to try

- `pgrep -a -f collector` — the three PIDs and full command lines.
- `ps -o pid,user,etimes,cmd -p "$(pgrep -f collector2)"` — confirm the candidate.
- `sudo strace -p "$(pgrep -f collector2)" -e trace=kill` — quiet until the periodic `kill(…, SIGCONT)` fires.
- `sudo readlink -f /proc/"$(pgrep -f collector2)"/exe` — the real backing binary (`/bin/bash`, since these are scripts).
- Stop one: `sudo systemctl stop collector3` — then `pgrep -f collector3` returns nothing and `/proc/<old-pid>` is gone.

## When you're done

```sh
astrona destroy strace-process-forensics
```
