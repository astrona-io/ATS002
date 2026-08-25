# Chapter 2: Process Limits — pid_max, ulimit, and the Three Ceilings

Picture a parking garage. Every car that enters needs a ticket with a unique number printed on it, and the machine that prints those tickets only has so many numbers before it has to start reusing them. Now imagine three separate barriers protecting that garage: one capping the *total* number of tickets the whole building can ever have in circulation at once, one capping how many tickets *your specific company* is allowed to hold at any moment, and one capping how many tickets a *specific department's reserved section* is allowed to use. Hit any one of those three barriers, and cars start getting turned away — even if the other two limits still have plenty of room.

That is almost exactly what happens when a Linux workload starts spawning processes and threads aggressively. There isn't one ceiling, there are three, and they are enforced completely independently of each other. This chapter walks through all three, because "fixing" only one of them is one of the most common ways an incident quietly resurfaces an hour later.

---

## Part I: What a PID Actually Costs You

Under Linux, every process — and, critically, every individual *thread* inside a multi-threaded process — consumes a unique numeric identifier drawn from the exact same pool. Linux doesn't maintain a separate "thread ID" namespace distinct from the process ID namespace at the kernel level; `gettid()` and `getpid()` return the same value for a single-threaded process, and every additional thread that process spawns eats another slot from that same shared pool.

This matters enormously in practice. A process with 500 worker threads doesn't consume "one" unit of PID space — it consumes roughly 500. A workload that forks aggressively *and* spawns large thread pools inside each fork can walk straight into the PID ceiling while barely dented CPU and memory usage sit there looking perfectly healthy.

The kernel parameter governing the size of that pool is `kernel.pid_max`. Read it the same two ways you learned for any other sysctl value:

```bash
sysctl -n kernel.pid_max
cat /proc/sys/kernel/pid_max
```

`man 5 proc` documents this parameter directly — it's one greater than the largest PID/TID the kernel will hand out. Its traditional default is `32768` (2¹⁵), a number inherited from a much older, far lower-core-count era of computing. A modern 64-bit kernel can support values as high as `4194304` (2²²) — a six-figure jump that costs nothing to enable and buys enormous headroom for thread-heavy workloads.

Before touching anything, confirm the failure is actually a PID-exhaustion problem and not garden-variety memory or CPU pressure:

```bash
free -m
top -bn1 | head -5
dmesg | tail -30 | grep -iE 'fork|cannot allocate|out of memory'
```

A workload throwing `fork: retry: Resource temporarily unavailable` or `pthread_create failed` on an otherwise idle box is the signature you're looking for. You can even count what's actually in flight and compare it against the ceiling directly:

```bash
ps -eLf | wc -l
```

The `-L` flag is the key detail — it counts threads too, not just top-level processes, giving you the true number of scheduled tasks competing for that shared pool.

---

## Part II: Raising the First Ceiling — kernel.pid_max

Raising it live, immediately, is a one-line fix:

```bash
sudo sysctl -w kernel.pid_max=4194304
```

But by now this pattern should feel familiar from Chapter 1 — a bare `sysctl -w` is a whiteboard scribble, gone at the next reboot. Persist it the exact same way you'd persist any other sysctl parameter:

```bash
echo "kernel.pid_max = 4194304" | sudo tee /etc/sysctl.d/98-pid-max.conf
sudo sysctl --system
```

No new mechanism to learn here — it's the identical `/etc/sysctl.d/*.conf` + `sysctl --system` pattern, just applied to a different key. That's the whole point of understanding sysctl as a *system* rather than memorizing individual parameters one at a time.

---

## Part III: The Second Ceiling — ulimit -u, a Per-User Cap

Here's where the "fixed it, and it broke again" trap springs. Raising `pid_max` widens the *whole system's* pool, but it does nothing whatsoever to a completely separate, independently-enforced ceiling: how many processes a single user is allowed to own.

```bash
ulimit -u
ulimit -Hu
```

`man bash`, in the `SHELL BUILTIN COMMANDS` section under `ulimit`, documents `-u` as "max user processes" — the soft limit by default, with `-H` showing the hard ceiling that value could be raised to (without needing root) if it ever needed to go higher. This is enforced by the kernel via `RLIMIT_NPROC`, scoped to the real UID actually running the workload — it's a completely separate accounting path from the global `pid_max` pool.

A common distro default caps this at a few thousand. If your thread-heavy workload needs tens of thousands, raising `pid_max` to the millions accomplishes nothing until this ceiling moves too. Raise it live for the current shell:

```bash
ulimit -u 32768
```

But — and this is the trap inside the trap — `ulimit` set interactively only affects your *current shell and its future children*. It is itself completely non-persistent, in a different sense than `sysctl -w`: it doesn't even survive you closing this terminal, let alone a reboot. The persistent equivalent lives in an entirely different file family:

```bash
# /etc/security/limits.d/data-processing.conf
dataproc soft nproc 32768
dataproc hard nproc 65536
```

`man 5 limits.conf` explains that this file is read by `pam_limits` at *login time* — meaning the new ceiling only applies to sessions that authenticate *after* the file is in place. A shell that's already open keeps its old limit until it logs in fresh again. If you edit this file and then wonder why a long-running session still shows the old number, that's not a bug — it's the file working exactly as documented.

---

## Part IV: The Third Ceiling — systemd's TasksMax=

If the workload in question runs as a systemd service rather than an interactive shell, there is a *third* independent ceiling sitting in the cgroup layer: `TasksMax=`.

```bash
systemctl show data-ingest.service --property=TasksMax,TasksCurrent
```

`man systemd.resource-control`, searching for `TasksMax`, explains that this counts every process *and* thread inside the unit's cgroup — the same "threads count too" principle from Part I, just enforced at a narrower scope. If a unit doesn't set its own `TasksMax=`, it inherits `DefaultTasksMax=` from `/etc/systemd/system.conf`, which itself is commonly a *percentage* of `pid_max` — meaning raising `pid_max` can nudge this default upward, but not reliably far enough to matter for a genuinely thread-heavy job, since it's a percentage calculated once, not a value that stays live-linked to `pid_max` forever after.

Raise it for exactly the one unit that needs it:

```bash
sudo systemctl edit data-ingest.service
```

```ini
[Service]
TasksMax=infinity
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart data-ingest.service
```

`TasksMax=infinity` removes the per-unit cap entirely, falling back to whatever `pid_max` and `ulimit` still constrain. In production, a specific high number is usually a more defensible choice than `infinity` — it keeps one runaway unit from being able to starve every other service on the box of PID space, which is exactly the kind of safety rail `TasksMax=` exists to provide in the first place.

Notice the override file alone isn't enough — `daemon-reload` tells systemd to re-read unit definitions, and the unit typically needs a restart before the new cgroup limit actually applies to it; an override sitting on disk does nothing to a cgroup that's already running under the old number.

---

## Part V: The Three-Layer Triage Method

When a "cannot fork" incident lands on your desk, the diagnostic order that actually works is:

1. **Global**: `sysctl -n kernel.pid_max` — is the whole system's pool too small?
2. **Per-user**: `ulimit -u` (as the user actually running the workload) — is this specific account capped below what it needs?
3. **Per-unit**: `systemctl show <unit> --property=TasksMax,TasksCurrent` — if it's a systemd service, is its cgroup capped independently of the first two?

Check all three, every time. A task or an incident that only ever inspects `kernel.pid_max` and calls it done is answering roughly one-third of the actual question — and the other two-thirds have a habit of reappearing at the worst possible moment.

---

## Self-Check and Verification

1. **Threads and PIDs**: Does a process's threads share one PID, or does each one consume its own slot from the pool? *(Answer: each thread consumes its own slot — the pool is shared between processes and threads.)*
2. **Independence**: If you raise `pid_max` to its maximum and a job still fails to fork, what should you check next? *(Answer: `ulimit -u` for the job's user, then the systemd unit's `TasksMax=` if it runs as a service — both are independent of `pid_max`.)*
3. **Where persistence lives**: Name the three separate files/mechanisms that persist each of the three ceilings. *(Answer: `/etc/sysctl.d/*.conf` for `pid_max`; `/etc/security/limits.d/` for `ulimit -u`; a systemd unit override (or `/etc/systemd/system.conf`) for `TasksMax=`.)*

You now have the full three-ceiling model. The hands-on lab hands you a workload that's hitting exactly this failure mode — diagnose it the same way, layer by layer.
