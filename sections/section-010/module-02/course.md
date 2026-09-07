# Chapter 2: Process Limits — pid_max, ulimit, and the Three Ceilings

When a Linux workload starts spawning processes and threads aggressively and begins getting `fork: retry: Resource temporarily unavailable`, there is not one limit in its way — there are three, enforced by three different kernel subsystems, completely independently of each other. Raising only one is the most common way an incident goes quiet for an hour and then comes back. This module walks all three: the machine-wide task pool (`kernel.pid_max`), the per-user cap (`ulimit -u` / `RLIMIT_NPROC`), and the per-service cgroup cap (`TasksMax=`) — how to tell which one is clamping, how to raise each so it sticks, and the fixed order to check them in.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — The shared PID pool and confirming exhaustion](./course-01-the-shared-pid-pool.md)** — why every thread costs a slot from the same pool as processes, what `kernel.pid_max` actually means, PID wraparound, and the `free` / `top` / `ps -eLf` check that confirms the failure is PID exhaustion and not memory or CPU.
2. **[Part 2 — The three independent ceilings](./course-02-the-three-independent-ceilings.md)** — each ceiling side by side: what enforces it, what scope it covers (machine / real UID / unit cgroup), where its persistent setting lives, and why a `fork()` must clear all three.
3. **[Part 3 — Raising each ceiling, in order](./course-03-raising-each-ceiling-in-order.md)** — live and persistent change for each (sysctl drop-in; `limits.d` + why an open session keeps its old limit; `systemctl edit` + `daemon-reload` + restart), and the global → per-user → per-unit triage method.

## Learning objectives

After this module you can:

- **Explain** why a multi-threaded process consumes many PID-pool slots, not one, and read `kernel.pid_max` as one greater than the highest PID.
- **Confirm** that a "cannot fork" failure is PID exhaustion rather than memory or CPU pressure.
- **Name** the three independent ceilings, the subsystem that enforces each, and the scope each applies to.
- **Predict** which ceiling is clamping a workload from its user, its unit, and the system-wide task count.
- **Raise** each ceiling both live and persistently, using the correct file family for each.
- **Explain** why editing `/etc/security/limits.d/` does not change an already-open session, and why a `TasksMax=` override needs `daemon-reload` and a restart.
- **Apply** the global → per-user → per-unit triage order so a fix does not resurface.

## Before you start

Assumed: Chapter 1 (`sysctl -w` vs `/etc/sysctl.d/` + `sysctl --system`), a Linux shell, `sudo`, and the idea of a systemd service. Familiarity with soft vs hard resource limits helps but is introduced here. There is no dedicated playground; every command block states the shell, user, and privilege it assumes, and runs on any systemd Linux host.

## Where this fits

This module is the second in the section and reuses Chapter 1's "live value vs. persistent config" model three times over — once per ceiling, each with its own file family. It is also the first place the section's recurring "fixed one layer, the problem moved to the next" pattern appears explicitly. The section capstone stages a workload hitting exactly this failure mode and expects the layered diagnosis, not a single `pid_max` bump.
