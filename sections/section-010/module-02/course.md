# Process Limits — pid_max, ulimit, and the Three Ceilings

Astronaut, a busy ship needs many hands. When a Linux workload starts lots of processes and threads, it can suddenly fail with `fork: retry: Resource temporarily unavailable`. There is not one limit in its way. There are three, and three different parts of the system enforce them, completely apart from each other. Raising only one of them is the most common way an incident goes quiet for an hour and then comes back.

This module walks through all three: the machine-wide pool of task numbers (`kernel.pid_max`), the per-user cap (`ulimit -u`, also called `RLIMIT_NPROC`), and the per-service cap (`TasksMax=`). You learn how to tell which one is holding the workload back, how to raise each one so the change lasts, and the fixed order to check them in.

## Learning objectives

After this module you can:

- **Explain** why a process with many threads uses many slots of the PID pool, not one, and read `kernel.pid_max` as one more than the highest PID.
- **Confirm** that a "cannot fork" failure is PID exhaustion rather than memory or CPU pressure.
- **Name** the three independent ceilings, the part of the system that enforces each, and how far each one reaches.
- **Predict** which ceiling is holding a workload back from its user, its unit and the number of tasks on the machine.
- **Raise** each ceiling both live and permanently, using the right kind of file for each.
- **Explain** why editing `/etc/security/limits.d/` does not change a session that is already open, and why a `TasksMax=` override needs `daemon-reload` and a restart.
- **Apply** the order "whole machine, then user, then service" so that a fix does not come back.

## Before you start

Check that you have what this module expects before you begin.

### What you should already know

- **How kernel parameters work.** `sysctl -w` changes a value in the running kernel only. A file under `/etc/sysctl.d/` plus `sudo sysctl --system` changes it now and on every boot.
- **How to use a Linux shell** with `sudo`.
- **What a systemd service is.** It is a program that systemd starts and watches, described by a unit file.

It helps if you know the difference between soft and hard resource limits, but the parts explain it.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with a user called `dataproc` and a demo service, `data-ingest.service`, running with `TasksMax=64`. So each of the three ceilings has something real to look at. It is a throwaway machine with no task and no grading, so experiment freely.

Start it, then open a terminal on it with `astrona ssh astro-process-limits-ceilings`:

<!-- astrona:playground -->

Every command block in the parts also says which shell, which user and which rights it expects.

## How this module is laid out

1. [The Shared PID Pool](./course-01-the-shared-pid-pool.md): why every thread takes a slot from the same pool as processes, what `kernel.pid_max` means, how PID numbers wrap around, and the `free`, `top` and `ps -eLf` check that proves the failure is PID exhaustion.
2. [The Three Independent Ceilings](./course-02-the-three-independent-ceilings.md): each ceiling side by side, with what enforces it, how far it reaches (machine, real user, unit cgroup), where its permanent setting lives, and why a `fork()` must pass all three.
3. [Raising The Kernel And User Ceilings](./course-03-raising-the-kernel-and-user-ceilings.md): live and permanent changes for `kernel.pid_max` and `ulimit -u`, and why an open session keeps its old limit.
   - Mission: [Process Limits: Diagnose the Single Clamp (ulimit -u) Lab](./labs/lab-02/README.md)
4. [Raising TasksMax And The Triage Order](./course-04-raising-tasksmax-and-the-triage-order.md): a `TasksMax=` override with `daemon-reload` and a restart, and the fixed order to check all three ceilings.
   - Mission: [Process & Thread Ceilings Lab](./labs/lab-01/README.md)
   - Mission: [Process Limits: Diagnose the Single Clamp (TasksMax) Lab](./labs/lab-03/README.md)
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md)

## Why this matters

"Fixed one layer, and the problem moved to the next" is a pattern you will meet again and again in Linux troubleshooting. Process limits show it more clearly than almost anything else. On the exam you may get a workload that hits exactly this failure, and the task expects a check of every layer, not a single `pid_max` bump.
