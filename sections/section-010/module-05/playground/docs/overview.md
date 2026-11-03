# Overview: strace Process Forensics Playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh`, and waits for you. There is no task, no `astrona submit`, and no pass or fail.

## What is in the box

- One Ubuntu 24.04 virtual machine (`qemu`). Open a terminal on it with `astrona ssh astro-strace-process-forensics`.
- `strace`, and the `procps` tools `pgrep` and `ps`.
- Three background services, **`collector1`, `collector2` and `collector3`**. Each one is a small shell script at `/usr/local/bin/collectorN`, run by its own systemd unit. All three loop on `sleep`. **`collector2` also makes a `kill()` system call about every 10 seconds** (it sends itself `SIGCONT`), so `strace -e trace=kill` has something real to catch.
- `kernel.yama.ptrace_scope` is at its default (`1`), so attaching to these processes needs `sudo`.
- `lsblk` shows `vda` (the 15 GiB operating system disk) and `vdb` (a small cloud-init disk of about 366 KiB). There are no extra disks.

## Things to try

- `pgrep -a -f collector`: the three PIDs and their full command lines.
- `ps -o pid,user,etimes,cmd -p "$(pgrep -f collector2)"`: check the candidate's owner and age.
- `sudo strace -p "$(pgrep -f collector2)" -e trace=kill`: quiet until the regular `kill(…, SIGCONT)` happens.
- `sudo readlink -f /proc/"$(pgrep -f collector2)"/exe`: the real program file. It is `/bin/bash`, because these are scripts.
- Stop one with `sudo systemctl stop collector3`. Then `pgrep -f collector3` returns nothing, and `/proc/<old-pid>` is gone.

## When you are done

```sh
astrona destroy strace-process-forensics
```
