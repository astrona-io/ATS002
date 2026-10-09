# Overview: Kernel Modules Playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh`, and waits for you. There is no task, no `astrona submit`, and no pass or fail.

## What is in the box

- One Ubuntu 24.04 virtual machine (`qemu`) with its **own real kernel**, so `modprobe` really loads and unloads modules. Open a terminal on it with `astrona ssh astro-kernel-modules-lab`.
- The `kmod` tools: `lsmod`, `modprobe`, `modinfo`, `depmod` and `rmmod`.
- Nothing is loaded or configured. `/etc/modules-load.d/` and `/etc/modprobe.d/` hold only the Ubuntu defaults.
- The **`dummy`** module (a virtual network driver) ships with the kernel and can always be loaded. `pcspkr`, the real-world blacklist example in the course text, may not exist for a virtual machine kernel, so the hands-on steps use `dummy` for both loading and blacklisting.
- `lsblk` shows `vda` (the 15 GiB operating system disk) and `vdb` (a small cloud-init disk of about 366 KiB). There are no extra disks.

## Things to try

- `lsmod | head` and `cat /proc/modules | head`: the same data from two sources.
- `modinfo -p dummy`: its one parameter, `numdummies (int)`.
- `sudo modprobe dummy numdummies=2`, then `cat /sys/module/dummy/parameters/numdummies` and `ip link show type dummy`.
- `sudo modprobe -r dummy`, then save the line `options dummy numdummies=2` in a file such as `/etc/modprobe.d/dummy.conf`. Load the module with a bare `sudo modprobe dummy` and read the parameter again.
- Save the line `blacklist dummy` as `/etc/modprobe.d/bl-dummy.conf`. Then confirm that `sudo modprobe dummy` still works: a blacklist only blocks automatic loads, not explicit ones.

## When you are done

```sh
astrona destroy kernel-modules-lab
```
