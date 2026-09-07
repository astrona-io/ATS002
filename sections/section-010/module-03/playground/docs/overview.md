# Overview — kernel-modules playground

A **playground**, not a lab: boots, runs `bootstrap/prepare.sh`, waits. No task, no `astrona submit`, no pass/fail.

## What's in the box

- One Ubuntu 24.04 qemu VM with its **own real kernel** — `modprobe` genuinely loads and unloads modules. Reached with `astrona ssh astro-kernel-modules-lab`.
- `kmod` tooling: `lsmod`, `modprobe`, `modinfo`, `depmod`, `rmmod`.
- Nothing is loaded or configured. `/etc/modules-load.d/` and `/etc/modprobe.d/` hold only distro defaults.
- The **`dummy`** virtual-NIC module is in-tree and always loadable. `pcspkr` (the module text's real-world blacklist example) may not exist for a VM kernel — the hands-on checkpoints use `dummy` for both loading and blacklisting.
- `lsblk` shows `vda` (~15 GiB OS disk) and `vdb` (~366 KiB cloud-init disk). No extra disks.

## Things to try

- `lsmod | head` and `cat /proc/modules | head` — same data, two sources.
- `modinfo -p dummy` — its one parameter, `numdummies (int)`.
- `sudo modprobe dummy numdummies=2`, then `cat /sys/module/dummy/parameters/numdummies` and `ip link show type dummy`.
- `sudo modprobe -r dummy`, add `options dummy numdummies=2` under `/etc/modprobe.d/`, `sudo modprobe dummy` (bare), re-check the parameter.
- `echo 'blacklist dummy' | sudo tee /etc/modprobe.d/bl-dummy.conf` — then confirm `sudo modprobe dummy` still works (explicit load), only auto-load is blocked.

## When you're done

```sh
astrona destroy kernel-modules-lab
```
