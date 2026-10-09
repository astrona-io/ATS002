# Reading and Reshaping the Live Kernel with sysctl

Welcome aboard, astronaut. Your ship runs on a reactor core, the Linux **kernel**, and the reactor has a control panel with thousands of dials. These dials are **kernel parameters**. They decide how eagerly the kernel swaps memory, whether it passes network packets on, how many process numbers it can hand out, and much more. You can read almost all of them, and change most of them, while the ship is flying.

All the dials live in one special folder, `/proc/sys`, and the friendly tool to read and turn them is `sysctl`. One contrast makes this a real exam topic. A change made with `sysctl -w` works at once but is gone at the next reboot. A change written into the right file under `/etc` works at once *and* survives every reboot. Telling those two apart is the whole exam objective.

## Learning objectives

After this module you can:

- **Extract** the kernel release with the correct `uname` option and write it into a file, without a parsing step and without a missing-folder failure.
- **Explain** how a dotted sysctl name maps to its `/proc/sys` file, and read a live value both with `sysctl -n` and with `cat`.
- **Distinguish** the kernel's current value in memory from what a configuration file under `/etc` says it should be.
- **Predict** what a `sysctl -w` change will be after a reboot, and why.
- **Write** a `sysctl` change that is applied now and again on every boot, using a drop-in file and `sysctl --system`.
- **Resolve** which drop-in file wins when two of them set the same key.

## Before you start

Check that you have what this module expects before you begin.

### What you should already know

- **How to use a Linux shell.** You can type a command, use `sudo`, and send output into a file with `>`.
- **How to read a plain text file** with `cat`.

You need no earlier experience with kernel tuning.

### What is in your playground

Your playground is a training ship: one clean Ubuntu 24.04 virtual machine with its own real kernel. The `procps` tools (`sysctl`) and `systemd` (`timedatectl`) are already installed, and nothing has been changed for you. Because the kernel is real, `sysctl -w` and the drop-in files in the parts really change and keep kernel state. It is a throwaway machine with no task and no grading, so experiment freely.

Start it, then open a terminal on it with `astrona ssh astro-sysctl-live-kernel`:

<!-- astrona:playground -->

Every command block in the parts also says which shell and which rights it expects, so you can follow the text on any Ubuntu 24.04 machine too.

## How this module is laid out

1. [Identifying The Running Kernel](./course-01-identifying-the-running-kernel.md): the `uname` fields (`-r` release, `-v` build banner, `-a` everything), the `/proc` files that mirror them, and why `>` creates a file but never its folder.
2. [Every Sysctl Name Is A File](./course-02-every-sysctl-name-is-a-file.md): how each sysctl name maps to a `/proc/sys` path, and why `sysctl` is a thin wrapper over those files.
3. [Reading The Live Value](./course-03-reading-the-live-value.md): `-n` for the bare value, why a read shows the kernel's memory and not a file, and the same one-clean-field habit for `timedatectl`.
   - Mission: [sysctl Live Kernel State Lab](./labs/lab-01/README.md)
4. [Runtime Changes Live In Memory](./course-04-runtime-changes-live-in-memory.md): what `sysctl -w` really does, and what happens to its value at the next reboot.
5. [Persistent Changes And Which File Wins](./course-05-persistent-changes-and-which-file-wins.md): drop-in files under `/etc/sysctl.d/`, `sysctl --system`, and the rule for which file wins.
6. [Wrap-Up: Mission Debrief](./course-06-wrap-up.md)

## Why this matters

On the exam, and on a real server, a fix that only lives in memory is a problem that comes back after the next reboot. The habit you build here, "change it live, write it down, and check both", is the same habit you need for process limits, kernel module options and device names. Each of those has a live action and a file under `/etc` that a service reads again at boot.
