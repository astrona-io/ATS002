# Part 2 — Attaching and filtering the syscall stream

> Prerequisite: [Part 1 — From a name to the right PIDs](./course-01-from-a-name-to-the-right-pids.md). Next: [Part 3 — From confirmed process to safe cleanup](./course-03-from-confirmed-process-to-safe-cleanup.md).

`strace` shows every request a process makes to the kernel. Unfiltered on a busy process that is an unreadable torrent, and the one line you need scrolls away before you see it. This part is what `strace` actually does to attach, how to filter to just the syscall you are hunting, and how to watch long enough to make a "not seen" result mean something.

## What "attach" does

```bash
# shell: host, root
sudo strace -p 1235
```

`strace` uses the **`ptrace`** syscall to become the target's tracer. From then on the kernel stops the target on **every syscall entry and exit** and hands control to `strace`, which reads the registers (syscall number and arguments), decodes them, prints a line, and lets the target continue. Two consequences: the target runs **noticeably slower** while traced (every syscall is now two context switches into `strace` and back), and when `strace` detaches or is killed the target resumes at full speed.

`ptrace` attachment is gated by `kernel.yama.ptrace_scope` (a sysctl — Chapter 1):

| `ptrace_scope` | Who may attach to an already-running process |
|---|---|
| `0` | any process of the same UID |
| `1` (common default) | only a parent, or root |
| `2` | only root |
| `3` | nobody |

So on a typical box you need `sudo` to attach to a process you did not start — even one you own.

## Filter to the syscall you want

```bash
sudo strace -p 1235 -e trace=kill
```

`man strace`, `-e trace=`: name one syscall, a comma list (`-e trace=kill,tgkill,tkill`), or a **class** with a `%` prefix:

| Class | Covers |
|---|---|
| `%signal` | `kill`, `tgkill`, `rt_sigaction`, `rt_sigprocmask`, … |
| `%process` | `fork`, `clone`, `execve`, `exit`, `wait4`, … |
| `%file` | anything taking a path: `open`, `stat`, `unlink`, `execve`, … |
| `%network` | `socket`, `connect`, `bind`, `sendto`, … |
| `%desc` | file-descriptor ops: `read`, `write`, `close`, `dup`, … |

With `-e trace=kill` the terminal stays silent until a `kill()` actually fires.

> [!TIP]
> **Try it — attach and filter.** `collector2` sends itself a signal every ~10 s. On the host:
>
> ```bash
> cat /proc/sys/kernel/yama/ptrace_scope
> sudo strace -p "$(pgrep -f collector2)" -e trace=kill -tt
> ```
>
> Expect something like (after up to ~10 s):
>
> ```text
> 1
> strace: Process 733 attached
> 10:22:41.512  kill(733, SIGCONT)   = 0
> 10:22:51.514  kill(733, SIGCONT)   = 0
> ```
>
> `ptrace_scope` is `1`, which is why the attach needs `sudo`. The terminal is silent between firings — everything except `kill()` is filtered out. `Ctrl-C` to detach (the process then runs full-speed again).

Useful companions:

- **`-f`** — also trace children/threads the target spawns (`clone`). Essential for a multi-threaded or forking target.
- **`-tt`** — wall-clock timestamp (microseconds) on each line; **`-T`** — time spent in each call.
- **`-y`** — annotate fd numbers with the path/socket they refer to.
- **`-o file`** — write the trace to a file instead of the terminal.
- **`-p 1235,1236`** (modern strace) — attach to several PIDs at once.

## Watch long enough

If the behaviour is described as "periodic", a single glance proves nothing — you may just have looked between firings. Cover the interval. Watch the candidates in parallel rather than serially:

```bash
sudo strace -p 1234 -e trace=kill -tt 2>trace.1234 &
sudo strace -p 1235 -e trace=kill -tt 2>trace.1235 &
sudo strace -p 1236 -e trace=kill -tt 2>trace.1236 &
wait
```

```text
09:41:07.512901 kill(4592, SIGTERM)     = 0
```

That line is attributable to whichever session's output it appears in — `collector2` (PID 1235) is now **confirmed with evidence**, not suspected. A process that emits nothing across an observation window that comfortably spans the suspected interval is presumed clean. If you do not know the cadence, a cron entry, a systemd timer, or an application log usually hints at it.

> [!WARNING]
> - **Concluding "innocent" from a short watch.** For periodic behaviour, the window must exceed the period. Absence over 20s means nothing if the action runs every 5 minutes.
> - **Forgetting `-f` on a threaded target.** The syscall may be made by a child thread `strace` is not following without `-f`.
> - **Leaving `strace` attached and walking away.** The target runs slowed the whole time; detach (`Ctrl-C`) once you have what you need.
> - **Expecting to attach without root.** `ptrace_scope=1` blocks same-UID attach to a process you did not fork; `sudo` is normal here.

> *`strace` `ptrace`-attaches and stops the target on every syscall (slowing it); `-e trace=<syscall>` or `%class` filters to what you are hunting, `-f` follows threads, and a "not seen" result only counts if the watch outlasts the suspected interval.*

## Reference

- `man strace` — `-e trace=` syntax and every `%class`, plus `-f`, `-p`, `-tt`, `-T`, `-y`, `-o`.
- `man 2 ptrace` — attach semantics and why a traced process runs stopped-then-resumed per syscall.
- `man 2 ptrace` "Ptrace access mode checking" / `Documentation/admin-guide/LSM/Yama.rst` — what each `ptrace_scope` value allows.
