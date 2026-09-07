# Part 1 — The shared PID pool and confirming exhaustion

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — The three independent ceilings](./course-02-the-three-independent-ceilings.md).

Before raising any limit you need to be sure the failure is *PID exhaustion* and not memory or CPU pressure wearing the same clothes. This part is the pool itself — what draws from it, how big it is, how numbers get reused — and the three-command check that confirms "cannot fork" really means "out of task slots".

## Threads and processes draw from one pool

Concrete: a service with 500 worker threads is not "one" task to the kernel — it is roughly 500.

Linux does not keep a separate thread-ID space. At the kernel level a thread *is* a task, created by `clone()` with shared address space, and it gets its own entry in the task table and its own **TID** drawn from the same integer pool that process IDs come from. For a single-threaded process `getpid()` and `gettid()` return the same number; every extra thread consumes one more slot.

The consequence for capacity planning: a workload that forks aggressively *and* runs large thread pools inside each fork can hit the task-slot ceiling while `top` shows CPU and memory sitting comfortably idle. Nothing in the CPU/RAM picture warns you.

## `kernel.pid_max` sizes the pool

```bash
# shell: any host, unprivileged
sysctl -n kernel.pid_max
cat /proc/sys/kernel/pid_max
```

```text
32768
```

`kernel.pid_max` is **one greater than the largest PID/TID the kernel will allocate** — so `32768` means PIDs `1`..`32767`. That default is `2^15`, a number inherited from single-core-era Linux. A 64-bit kernel accepts up to `4194304` (`2^22`); raising it costs a few bytes of bookkeeping per possible task and buys enormous headroom.

Numbers are handed out roughly sequentially and then **wrap**: after the allocator reaches `pid_max` it wraps to the low end and skips values still in use. A too-small `pid_max` on a churny box means the allocator is constantly stepping over live PIDs looking for a free slot — and when none is free, `fork()` / `clone()` returns `EAGAIN`.

## Confirm it is actually PID exhaustion

Rule out the look-alikes first:

```bash
# shell: host
free -m
top -bn1 | head -5
dmesg | tail -30 | grep -iE 'fork|cannot allocate|out of memory|task'
```

The signature of PID exhaustion specifically: `fork: retry: Resource temporarily unavailable`, `pthread_create failed`, `-bash: fork: Cannot allocate memory` (misleading text — still `EAGAIN`, not real OOM) **on a box whose `free -m` and `top` look healthy**. If `dmesg` shows the OOM killer firing, that is a different problem — memory, not slots.

Then count what is actually scheduled and compare it to the ceiling:

```bash
ps -eLf | wc -l
```

`-L` is the flag that matters: it prints **one line per thread**, not per process, so the count is the true number of tasks competing for the pool. Compare that to `sysctl -n kernel.pid_max`. Close to the ceiling → this part's problem. Far below it → the ceiling in Part 2 that is actually clamping you is a narrower one.

> [!TIP]
> **Try it — pool size vs. what's running.** On the playground host (`astrona ssh astro-process-limits-ceilings`):
>
> ```bash
> sysctl -n kernel.pid_max
> ps -e | wc -l          # processes
> ps -eLf | wc -l        # processes AND threads
> ```
>
> Expect something like:
>
> ```text
> 4194304
> 142
> 380
> ```
>
> The thread count (`-eLf`) is well above the process count — every one of those extra lines is a slot from the same pool. On this idle VM both are a rounding error against `pid_max`, so a "cannot fork" here would point at Part 2's narrower ceilings, not this one.

> [!WARNING]
> - **Trusting `top`'s task count.** The summary line counts processes; a thread-heavy workload's real task count comes from `ps -eLf | wc -l`.
> - **Reading `Cannot allocate memory` as OOM.** `fork()` returns `EAGAIN` on PID exhaustion and glibc renders it with that string. Check `free -m` and the OOM-killer lines in `dmesg` before concluding it is memory.
> - **Fixing before confirming.** Raising `pid_max` on a box that is actually short on RAM changes nothing and wastes the maintenance window.

> *Every process and every thread takes one slot from the single pool sized by `kernel.pid_max` (one past the highest PID); confirm exhaustion with a healthy `free`/`top` plus `fork: … Resource temporarily unavailable` and `ps -eLf | wc -l` near the ceiling.*

## Reference

- `man 5 proc` — `/proc/sys/kernel/pid_max` defined as one greater than the maximum PID.
- `man 2 fork` / `man 2 clone` — the `EAGAIN` return and the two limits that cause it (system-wide and `RLIMIT_NPROC` — Part 2).
- `man 1 ps` — `-L` (per-thread rows) and `-e` (all processes).
