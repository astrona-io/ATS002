# Kernel Modules: Loading, Parameters, and Blacklisting

Astronaut, most of what your ship's reactor core can do was not built into it. It is fitted while flying, as **kernel modules**: plug-in reactor parts such as device drivers, filesystems and network protocol handlers. Like the reactor's dials, these parts can be tuned with parameters, set to load at every launch, or blocked so they never load on their own, even when their hardware is present.

This module teaches all of that. It also teaches the one difference every blacklist question turns on: an *automatic* load is not the same as an *explicit* one.

## Learning objectives

After this module you can:

- **Read** `lsmod` output (name, size, reference count, dependent modules) and get the same data from `/proc/modules`.
- **Discover** a module's accepted parameters and their types with `modinfo -p` before loading it.
- **Explain** why `modprobe` succeeds where `insmod` fails, using the `modules.dep` dependency map.
- **Load** a module with a non-default parameter and check the value in `/sys/module/<name>/parameters/`.
- **Choose** the right configuration file for "load at boot" and for "load with these parameters", and combine both when needed.
- **Explain** exactly what a `blacklist` entry blocks and what it does not, and name the directive that also blocks an explicit `modprobe`.
- **Replay** hardware detection with `udevadm trigger`, and say when the initramfs must be rebuilt too.

## Before you start

Check what this module expects you to know, and what is waiting in your playground.

### What you should already know

- **A Linux shell and `sudo`.** You can type commands and borrow the captain's authority for the ones that change the system.
- **`/proc` and `/sys`.** These folders are not files on disk. The kernel fills them with live values when you read them.
- **The `/etc/*.d/` pattern.** Many tools read every `.conf` file in a folder under `/etc` at start-up, so you add a setting by dropping in a small file.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with its **own real kernel**, so `modprobe` really loads and unloads modules. The `kmod` tools (`lsmod`, `modprobe`, `modinfo`, `depmod`, `rmmod`) are installed, and nothing is loaded or configured when it starts. The hands-on steps use the `dummy` module, which is always available. The text keeps `pcspkr` as the real-world blacklist example, but it may not exist for a virtual machine kernel.

Start the playground, then open a terminal on it with `astrona ssh astro-kernel-modules-lab`. Every command block also says which shell and which privileges it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Inspecting Modules And Their Parameters](./course-01-inspecting-modules-and-parameters.md): `lsmod` and `/proc/modules`, reference counts, `modinfo -p`, and live values in `/sys/module/<name>/parameters/`.
2. [Loading Modules With Modprobe](./course-02-loading-modprobe-and-dependencies.md): `modprobe` versus `insmod`, the `modules.dep` map that `depmod` builds, unloading, and a parameter for one load.
3. [Loading Modules At Boot With Options](./course-03-loading-at-boot-with-options.md): `/etc/modules-load.d/` for "load it" and `/etc/modprobe.d/` `options` for "with these parameters", proved without a reboot.
4. [Blacklisting Modules](./course-04-blacklisting-modules.md): what `blacklist` blocks and what it does not, `install ... /bin/false`, `udevadm trigger`, and the initramfs.
   - Mission: [Kernel Module Loading & Blacklisting Lab](./labs/lab-01/README.md)
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md)

## Why this matters

Exam tasks about modules almost always have two halves: change the running system now, and make sure the change survives a reboot. Get only one half right and the task fails. A blacklist that you think blocks everything, but that only blocks automatic loads, is the classic trap. This module trains you to prove each half with a check command.
