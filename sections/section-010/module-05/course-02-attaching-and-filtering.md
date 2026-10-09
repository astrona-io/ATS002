# Attaching And Filtering The Syscall Stream

Astronaut, every time a crew member needs something from the reactor core, such as opening a hatch, reading a file or sending a signal, they make a request called a **system call** (syscall). `strace` is the flight recorder clipped onto one crew member: it writes down every one of those requests. On a busy process, an unfiltered recording is a flood, and the one line you need scrolls away before you see it.

This part shows what `strace` does to attach, how to filter down to the one syscall you are hunting, and how long to watch before "not seen" means anything.

## What "attach" does

Attaching is not free. The process you watch runs differently while the recorder is clipped on.

### A real attach

<!-- astrona:playground:renew -->

```bash
# shell: host, root
sudo strace -p 1235
```

PID 1235 is an example. In your playground, use a PID that `pgrep -a -f collector` printed, and press `Ctrl-C` to stop.

`strace` uses the **`ptrace`** system call to become the target's tracer. From then on, the kernel stops the target at **every syscall entry and exit** and hands control to `strace`. `strace` reads the syscall number and its arguments, prints a line, and lets the target continue.

That has two effects. The target runs **noticeably slower** while traced, because every syscall now means two switches into `strace` and back. And when `strace` detaches or is stopped, the target runs at full speed again.

### Who may attach: `kernel.yama.ptrace_scope`

The kernel setting `kernel.yama.ptrace_scope` decides who may attach with `ptrace`. Like any kernel parameter, it is a dial on the reactor control panel, readable under `/proc/sys`:

| `ptrace_scope` | Who may attach to an already-running process |
|---|---|
| `0` | any process of the same UID |
| `1` (common default) | only a parent, or root |
| `2` | only root |
| `3` | nobody |

So on a typical Ubuntu machine you need `sudo` to attach to a process you did not start, even one you own.

## Filter to the syscall you want

Name the syscall you are hunting, and `strace` hides everything else.

### Filter to one syscall

```bash
sudo strace -p 1235 -e trace=kill
```

The `-e trace=` option takes one syscall, a comma-separated list (`-e trace=kill,tgkill,tkill`), or a **class** with a `%` prefix. With `-e trace=kill`, the terminal stays silent until a `kill()` really happens.

### Syscall classes

| Class | Covers |
|---|---|
| `%signal` | `kill`, `tgkill`, `rt_sigaction`, `rt_sigprocmask`, … |
| `%process` | `fork`, `clone`, `execve`, `exit`, `wait4`, … |
| `%file` | anything taking a path: `open`, `stat`, `unlink`, `execve`, … |
| `%network` | `socket`, `connect`, `bind`, `sendto`, … |
| `%desc` | file-descriptor ops: `read`, `write`, `close`, `dup`, … |

## Try it: attach and filter

In your playground, `collector2` sends a signal to itself about every 10 seconds. Read the `ptrace` setting, then attach to `collector2` and show only `kill()` calls, with a timestamp on each line:

```bash
cat /proc/sys/kernel/yama/ptrace_scope
sudo strace -p "$(pgrep -f collector2)" -e trace=kill -tt
```

Expect something like this, after up to about 10 seconds:

```text
1
strace: Process 733 attached
10:22:41.512  kill(733, SIGCONT)   = 0
10:22:51.514  kill(733, SIGCONT)   = 0
```

`ptrace_scope` is `1`, which is why the attach needs `sudo`. The terminal stays silent between the calls, because the filter hides everything except `kill()`. Press `Ctrl-C` to detach, and the process runs at full speed again.

### Useful companion options

- **`-f`** also traces the child processes and threads the target creates (with `clone`). You need it for a multi-threaded or forking target.
- **`-tt`** puts a wall-clock time stamp, in microseconds, on each line. **`-T`** shows the time spent in each call.
- **`-y`** shows the file path or socket behind each file descriptor number.
- **`-o file`** writes the trace to a file instead of the terminal.
- **`-p 1235,1236`** (recent `strace` versions) attaches to several PIDs at once.

## Watch long enough

If the behaviour is "periodic", one quick look proves nothing. You may simply have looked between two events.

### Watch every candidate at the same time

Cover the whole interval, and watch all candidates side by side instead of one after another:

```bash
sudo strace -p 1234 -e trace=kill -tt 2>trace.1234 &
sudo strace -p 1235 -e trace=kill -tt 2>trace.1235 &
sudo strace -p 1236 -e trace=kill -tt 2>trace.1236 &
wait
```

```text
09:41:07.512901 kill(4592, SIGTERM)     = 0
```

This sample line comes from a different machine, so its PID and signal differ from your playground's `kill(733, SIGCONT)`.

### What the result proves

The line belongs to whichever session's file it appears in. If it appears in `trace.1235`, then `collector2` (PID 1235) is **confirmed with evidence**, not just suspected. A process that records nothing across a watch that is clearly longer than the suspected interval is presumed clean.

If you do not know how often the action happens, look for hints: a cron job, a systemd timer or an application log usually shows the rhythm.

The manual pages `man strace` and `man 2 ptrace` describe every option and the attach rules in full.

> *`strace` attaches with `ptrace` and stops the target at every syscall, which slows it. `-e trace=<syscall>` or a `%class` filters to what you are hunting, `-f` follows threads, and a "not seen" result only counts if the watch lasts longer than the suspected interval.*

## Common pitfalls

> [!WARNING]
> - **Calling a process "innocent" after a short watch.** For periodic behaviour, the watch must be longer than the period. Twenty seconds of silence means nothing if the action runs every 5 minutes.
> - **Forgetting `-f` on a threaded target.** The syscall may come from a child thread, and `strace` does not follow it without `-f`.
> - **Leaving `strace` attached and walking away.** The target stays slow the whole time. Detach with `Ctrl-C` once you have what you need.
> - **Expecting to attach without root.** `ptrace_scope=1` blocks attaching to a process you did not start, even with the same user. `sudo` is normal here.
