# Chapter 1: Reading and Reshaping the Live Kernel with sysctl

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS002/tree/main/sections/section-010/module-01/playground)
>
> ```sh
> astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/playground
> astrona destroy sysctl-live-kernel
> ```

The Linux kernel exposes thousands of tunable values — how aggressively it swaps, whether it forwards packets, how large the process-ID pool is — and nearly all of them are readable, and most are writable, while the system runs. They live in one virtual filesystem, `/proc/sys`, and the friendly front end for reading and turning them is `sysctl`. The contrast that makes this a *topic* rather than a one-liner: a change you make with `sysctl -w` is real immediately and gone at the next reboot, while a change written into the right file under `/etc` is both immediate and permanent — and telling those apart is the whole exam objective.

This module is split into three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Identifying the running kernel](./course-01-identifying-the-running-kernel.md)** — the `uname` fields (`-r` release vs `-v` build banner vs `-a`), the `/proc` files that mirror them, and why `>` creates a file but never its parent directory.
2. **[Part 2 — /proc/sys and the live value](./course-02-proc-sys-and-the-live-value.md)** — every sysctl name as a `/proc/sys` path, `sysctl` as a thin wrapper over procfs, `-n` for the bare value, what "live / in-memory" means versus a config file, and the same one-clean-field instinct applied to `timedatectl`.
3. **[Part 3 — Runtime vs. persistent changes](./course-03-runtime-vs-persistent-changes.md)** — `sysctl -w` as a memory-only poke (with the reboot lifecycle), the `/etc/sysctl.d/` drop-in directories and their last-wins precedence, and `sysctl --system` as the one command that makes a change immediate *and* reboot-proof.

## Learning objectives

After this module you can:

- **Extract** the kernel release with the correct `uname` flag and redirect it into a file without a parsing step or a missing-directory failure.
- **Explain** the mapping from a dotted sysctl name to its `/proc/sys` file, and read a live value both with `sysctl -n` and with `cat`.
- **Distinguish** the kernel's current in-memory value from what a config file under `/etc` claims it should be.
- **Predict** what a `sysctl -w` change will be after a reboot, and why.
- **Write** a `sysctl` change that is both applied now and re-applied on every boot, using a drop-in file and `sysctl --system`.
- **Resolve** which drop-in file wins when two set the same key.

## Before you start

Assumed: a Linux shell, `sudo`, output redirection, and reading a plain text file. No prior kernel-tuning experience.

The playground (callout above) is a throwaway Ubuntu 24.04 VM with its own real kernel, so the `sysctl -w` and drop-in examples genuinely change and persist kernel state. Get a shell with `astrona ssh astro-sysctl-live-kernel`. The **Try it** checkpoints in Parts 1–3 run there; every command block also states the shell and privilege it assumes, so the text stands alone without the VM.

## Where this fits

This is the first module of the section and the pattern every later one reuses. Process limits (Chapter 2), kernel module parameters (Chapter 3), and udev names (Chapter 4) all have the same two-layer shape: a live action that changes the running system now, and a persistent config file under `/etc` that a boot-time service replays. Learn "live value vs. persistent config, and the command that does both" here and the rest of the section is which file and which apply command for each new subject.
