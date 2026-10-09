# The Three Independent Ceilings

Astronaut, a new crew member cannot come aboard just because there are badges left. Three different officers must each say yes. A `fork()` (the request to start a new process) does not check one limit. It checks three, and three different parts of the system enforce them. If **any** of the three is full, the request fails.

This part shows each ceiling: what enforces it, how far it reaches, and where its permanent setting lives.

## One failure, three possible causes

Start with a real case. A data-processing job runs as user `dataproc` and fails with `pthread_create failed` after about 4000 threads. `kernel.pid_max` is `4194304`, and `ps -eLf | wc -l` shows 9000 tasks on the whole machine.

The pool is nowhere near full. So the limit must be one of the two *narrower* ceilings.

## The three ceilings side by side

`clone()` and `fork()` must pass **all three** checks, or they fail with `EAGAIN`. The limit that really counts is the **lowest** of the three that applies to you.

| Ceiling | What it counts | How far it reaches | Who enforces it | Where it is kept |
| --- | --- | --- | --- | --- |
| 1. `kernel.pid_max` | the whole task-slot pool | the whole machine | the kernel's PID allocator | `/etc/sysctl.d/*.conf` |
| 2. `RLIMIT_NPROC` (`ulimit -u`) | processes and threads per real user | everything one user owns, across all sessions | the kernel, checked at `clone()` time | `/etc/security/limits.d/*.conf` (read by `pam_limits`) |
| 3. `TasksMax=` | processes and threads in one systemd unit's cgroup | one service and everything it starts | the cgroup `pids` controller | a unit drop-in, or `/etc/systemd/system.conf` |

### Ceiling 1: `kernel.pid_max` (the whole machine)

This is the size of the badge pool. It is a kernel parameter, it covers the whole machine, and it is the *only* one of the three that helps when the pool itself is really full. Raising it does nothing for a workload held back by ceiling 2 or 3.

### Ceiling 2: `ulimit -u` / `RLIMIT_NPROC` (per user)

Think of each user as an officer on the crew roster. `ulimit -u` says how many crew members one officer may have on duty at once.

<!-- astrona:playground:renew -->

Run this as the user that runs the workload:

```bash
# shell: as the user running the workload
ulimit -u        # soft limit — the one enforced now
ulimit -Hu       # hard limit — the ceiling the soft one may be raised to without root
```

```text
7877
15000
```

`man bash`, in the section on shell built-in commands, describes `-u` as "max user processes". The kernel enforces it as **`RLIMIT_NPROC`**. It counts against the **real user ID** of the process. So it limits all processes and threads that user owns, *across every session and service*, not per shell. It is a completely separate count from `pid_max`: you can be far below `pid_max` and still stuck at `RLIMIT_NPROC`.

There are two values. The **soft** limit is the one enforced now. A normal process may raise its own soft limit, but only up to the **hard** limit. Only `root` can raise the hard limit.

### Try it: the per-user cap for two users

On your playground, read your own soft and hard limits, then the soft limit of the `dataproc` user:

```bash
ulimit -u          # your shell's soft limit
ulimit -Hu         # the hard ceiling it could rise to
sudo -u dataproc bash -c 'ulimit -u'
```

Expect something like:

```text
7877
7877
7877
```

This is `RLIMIT_NPROC`. It counts against the real user ID and is shared by all of that user's sessions and services. It is nowhere near `kernel.pid_max`: two completely separate limits.

### Ceiling 3: `TasksMax=` (per systemd unit)

If the workload runs as a systemd service, there is a third cap. systemd is the ship's duty officer, and each service is a station. `TasksMax=` says how many crew members one station may hold, whoever they work for. You read it with `systemctl show`:

```bash
# shell: any host
systemctl show data-ingest.service -p TasksMax -p TasksCurrent
```

```text
TasksMax=9830
TasksCurrent=4102
```

A **cgroup** (control group) is the kernel's way to group processes and put limits on the whole group. `man systemd.resource-control` says that `TasksMax=` counts every process **and thread** in the unit's cgroup, through the cgroup `pids` controller. So threads count here too.

A unit with no `TasksMax=` of its own takes `DefaultTasksMax=` from `/etc/systemd/system.conf`. That default is often **15% of `kernel.pid_max`**, worked out once when systemd starts. Raising `pid_max` later nudges that default up, but not live. And 15% of even a large `pid_max` is often still less than a unit with very many threads needs.

### Try it: a per-unit cap that is neither of the other two

On your playground, `data-ingest.service` was started with `TasksMax=64`. Read its cap, its current task count and the default:

```bash
systemctl show data-ingest.service -p TasksMax -p TasksCurrent -p DefaultTasksMax
```

Expect something like:

```text
TasksMax=64
TasksCurrent=1
DefaultTasksMax=629145
```

`TasksMax=64` is this unit's own cgroup cap. It is far below `kernel.pid_max` (4194304) and `ulimit -u` (about 7877). It is also below `DefaultTasksMax` (15% of `pid_max`), which a unit *without* its own setting would get. A workload in this unit hits `64` first, however much room the other two ceilings have.

## Why "fixed it, broke again an hour later"

This is the classic failure. Someone decides an incident is PID exhaustion and raises `pid_max` into the millions. The workload recovers, only because a short spike passed. An hour later it hits `RLIMIT_NPROC` or `TasksMax=` and fails again with the same message.

The three ceilings are independent. Only the lowest one that applies to your workload matters. Raising a higher one changes nothing you can see until the real limit also moves.

## Common pitfalls

> [!WARNING]
> - **`ulimit -u` is per real user, not per shell.** All of a user's sessions and services share the count. Two heavy jobs under the same account compete for it.
> - **`TasksMax=` counts threads.** A unit with `TasksCurrent` near `TasksMax` but only a handful of *processes* is held back by threads, not processes.
> - **`DefaultTasksMax` is a snapshot, not a link.** Raising `pid_max` after systemd started does not raise the limit of units already running under the old default.
