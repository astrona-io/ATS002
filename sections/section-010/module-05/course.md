# Chapter 5: Catching a Process in the Act with strace

You are handed a process and told something in it is misbehaving, and you need proof — no source code, and the binary running now may not match anything in a repo. What you have is a live process, and Linux lets you stand next to it and watch every request it makes to the kernel. That tool is `strace`. This module is using it as a live-attach-and-filter instrument, plus the discipline that matters as much as the trace itself: resolving a process's real on-disk binary before you kill it, and never removing a path you guessed from its name.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — From a name to the right PIDs](./course-01-from-a-name-to-the-right-pids.md)** — the three names a process has (`comm`, `argv[0]`, executable path) and why they diverge for scripts, and `pgrep -a -f` matching the full command line so you confirm the exact PIDs before attaching.
2. **[Part 2 — Attaching and filtering the syscall stream](./course-02-attaching-and-filtering.md)** — what `ptrace` attachment does (and its performance cost), `kernel.yama.ptrace_scope` and why `sudo`, `-e trace=<syscall>` and `%class` filters, `-f` to follow threads, and watching long enough for "not seen" to mean something.
3. **[Part 3 — From confirmed process to safe cleanup](./course-03-from-confirmed-process-to-safe-cleanup.md)** — `/proc/PID/exe` as the kernel's authoritative pointer to the real binary, why you resolve it *before* killing, the `SIGTERM`→`SIGKILL` ladder, and removing only the captured path.

## Learning objectives

After this module you can:

- **Turn** a fuzzy process name into a confirmed PID list with `pgrep -a -f`, and explain why `-f` is required for an interpreted script.
- **Explain** what `strace` does to attach (`ptrace`, stop-per-syscall) and why it slows the target.
- **Filter** a trace to one syscall or a syscall class, and follow child threads with `-f`.
- **Justify** why a short observation window cannot prove a periodic behaviour absent.
- **Resolve** a process's real executable with `readlink -f /proc/PID/exe`, and explain why it must happen before the kill.
- **Terminate** a process with the `SIGTERM`→`SIGKILL` escalation, and remove only the captured canonical path.
- **Limit** action to processes you have confirmed, leaving unconfirmed neighbours running.

## Before you start

Assumed: a Linux shell, `sudo`, signals (`SIGTERM` / `SIGKILL`), and `/proc/PID/` basics from earlier chapters. `kernel.yama.ptrace_scope` is a sysctl (Chapter 1). There is no dedicated playground; every command block states the shell and privilege it assumes, and the techniques are safe to practise against a sleep loop or a test script you start yourself.

## Where this fits

This is the last teaching module of the section and the one that ties the live-diagnosis thread together: Chapter 1 read kernel state precisely, Chapter 2 covered the ceilings on how many processes can exist, Chapter 3 managed what module code the kernel runs, Chapter 4 gave devices trustworthy names — and here you catch a running process doing something it should not, then clean up in an order that preserves the evidence. The section capstone stages one incident that needs all five.
