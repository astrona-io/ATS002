# Chapter 3: Kernel Modules — Loading, Parameters, and Blacklisting

Most of what a running kernel can do was not compiled into the kernel image — it is loaded on demand as **modules**: device drivers, filesystems, protocol handlers. A module is kernel configuration applied at runtime, and like the sysctl values in Chapter 1 it can be tuned with parameters, made to load automatically at boot, or explicitly suppressed so it never auto-loads even with its hardware present. This module covers all of that, and the one distinction every blacklist question turns on: the difference between an *automatic* load and an *explicit* one.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Inspecting modules and their parameters](./course-01-inspecting-modules-and-parameters.md)** — `lsmod` / `/proc/modules` and what refcount means, `modinfo -p` for a module's declared parameters and types, and `/sys/module/<name>/parameters/` for a loaded module's live values.
2. **[Part 2 — Loading: modprobe, depmod, and the dependency graph](./course-02-loading-modprobe-and-dependencies.md)** — `modprobe` vs `insmod`, the `modules.dep` database that `depmod` builds, unloading with `modprobe -r` vs `rmmod`, passing a parameter for one load, and verifying it applied.
3. **[Part 3 — Persistence and blacklisting](./course-03-persistence-and-blacklisting.md)** — `/etc/modules-load.d/` (whether to load) vs `/etc/modprobe.d/` (`options` parameters, `blacklist`/`install` suppression), proving persistent config without a reboot, why `blacklist` only blocks automatic loads, and when the initramfs must be rebuilt.

## Learning objectives

After this module you can:

- **Read** `lsmod` output — name, size, reference count, dependent modules — and get the same data from `/proc/modules`.
- **Discover** a module's accepted parameters and their types with `modinfo -p` before loading it.
- **Explain** why `modprobe` succeeds where `insmod` fails, in terms of the `modules.dep` dependency graph.
- **Load** a module with a non-default parameter and verify the value via `/sys/module/<name>/parameters/`.
- **Choose** the correct config file for "load at boot" versus "load with these parameters", and combine both when needed.
- **Explain** exactly what a `blacklist` entry blocks and what it does not, and name the directive that also blocks an explicit `modprobe`.
- **Simulate** a hardware re-detection pass with `udevadm trigger`, and say when an initramfs rebuild is also required.

## Before you start

Assumed: Chapter 1 (`/proc` and `/sys` as live-value filesystems, the `/etc/*.d/` persistent-config pattern), a Linux shell, and `sudo`. There is no dedicated playground; every command block states the shell and privilege it assumes, and the `dummy` / `pcspkr` examples are safe to run on any ordinary Linux host.

## Where this fits

This is the module-management analogue of Chapter 1: a live action (`modprobe`) paired with a persistent config file under `/etc`, plus one new idea — the automatic-versus-explicit load distinction that blacklisting depends on, which returns in Chapter 4 when udev is the thing firing those automatic loads. The section capstone asks you to load and persist one module while blacklisting another in the same maintenance window.
