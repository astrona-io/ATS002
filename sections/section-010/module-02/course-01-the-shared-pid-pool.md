# The Shared PID Pool

Astronaut, every crew member on your ship wears a badge with a number. On Linux, a **process** is a crew member doing one job, and its badge number is its **PID** (process ID). The ship can only print a fixed number of badges. When they run out, nobody new can come aboard, even if there is plenty of air and food.

Before you raise any limit, you must be sure the failure really is "out of badges" and not a memory or CPU problem in disguise. This part shows what draws from the badge pool, how big the pool is, how numbers get reused, and the short check that proves "cannot fork" means "out of task slots".

## Threads and processes draw from one pool

Here is a concrete case: a service with 500 worker threads is not "one" task to the kernel. It is about 500.

A **thread** is like an extra pair of hands of the same crew member: it shares the crew member's memory but does its own work. Linux does not keep a separate number space for threads. Inside the kernel, a thread *is* a task. The kernel creates it with the `clone()` system call (a request to the kernel), and gives it its own entry in the task table and its own **TID** (thread ID). That TID comes from the same pool of numbers as process IDs.

For a process with one thread, `getpid()` and `gettid()` return the same number. Every extra thread uses one more slot.

This matters when you plan capacity. A workload that starts many processes, each with a large pool of threads, can run out of task slots while `top` shows CPU and memory sitting idle. Nothing in the CPU and memory picture warns you.

## `kernel.pid_max` sizes the pool

The size of the badge pool is the kernel parameter `kernel.pid_max`, a dial on the reactor's control panel.

<!-- astrona:playground:renew -->

Read it on any machine. You do not need `sudo`:

```bash
# shell: any host, unprivileged
sysctl -n kernel.pid_max
cat /proc/sys/kernel/pid_max
```

```text
32768
```

Note: `32768` is the old default built into the kernel. On Ubuntu 24.04 you will usually see `4194304`, because systemd raises the value at boot. The graded missions set `32768` on purpose so you have a real ceiling to fix.

### What the number means

`kernel.pid_max` is **one more than the largest PID or TID the kernel will hand out**. So `32768` means PIDs `1` to `32767`. That default is `2^15`, a number from the days of single-core machines. A 64-bit kernel accepts up to `4194304` (`2^22`). Raising it costs only a few bytes of bookkeeping per possible task, and buys a huge amount of room.

### How numbers are reused

The kernel hands out numbers roughly in order, then **wraps around**. When it reaches `pid_max`, it starts again at the low end and skips numbers that are still in use. If `pid_max` is too small on a busy machine, the kernel keeps stepping over live PIDs looking for a free one. When none is free, `fork()` or `clone()` fails with the error `EAGAIN` ("try again").

## Confirm it is really PID exhaustion

Some problems look like PID exhaustion but are not. Rule out memory and CPU pressure first, then count the tasks.

### Rule out the look-alikes

Check memory, the CPU summary and the kernel's own messages:

```bash
# shell: host
free -m
top -bn1 | head -5
dmesg | tail -30 | grep -iE 'fork|cannot allocate|out of memory|task'
```

The signature of PID exhaustion is one of these messages **on a machine where `free -m` and `top` look healthy**:

- `fork: retry: Resource temporarily unavailable`
- `pthread_create failed`
- `-bash: fork: Cannot allocate memory`

The last one is misleading: it can appear even though plenty of memory is free. If `dmesg` shows the OOM killer (the kernel's out-of-memory killer) firing, you have a different problem: memory, not task slots.

### Count every task

Then count what is actually running and compare it with the ceiling:

```bash
ps -eLf | wc -l
```

`-L` is the option that matters. It prints **one line per thread**, not per process, so the count is the true number of tasks using the pool. Compare it with `sysctl -n kernel.pid_max`. If the count is close to the ceiling, the pool itself is full. If it is far below, a narrower ceiling is stopping you: the per-user limit or the per-service limit.

### Try it: pool size against what is running

On your playground, read the pool size, then count processes and then processes plus threads:

```bash
sysctl -n kernel.pid_max
ps -e | wc -l          # processes
ps -eLf | wc -l        # processes AND threads
```

Expect something like:

```text
4194304
142
380
```

The thread count (`-eLf`) is well above the process count. Every extra line is one more slot from the same pool. On this idle machine both numbers are tiny next to `pid_max`. So a "cannot fork" here would point at one of the narrower ceilings, not at the pool.

## Common pitfalls

> [!WARNING]
> - **Trusting `top`'s task count.** Its summary line counts processes. The real task count of a workload with many threads comes from `ps -eLf | wc -l`.
> - **Reading `Cannot allocate memory` as out of memory.** `fork()` can fail with this text even when memory is free. Check `free -m` and the OOM killer lines in `dmesg` before you decide it is memory.
> - **Fixing before confirming.** Raising `pid_max` on a machine that is really short of memory changes nothing and wastes your maintenance window.
