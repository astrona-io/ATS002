# Part 3 — From confirmed process to safe cleanup

> Prerequisite: [Part 2 — Attaching and filtering the syscall stream](./course-02-attaching-and-filtering.md). Next: [Section 010 quiz](../quiz.md).

You have a confirmed PID. The remaining work has a strict order: resolve the real on-disk binary **first** (that information disappears the instant the process dies), then terminate, then remove — using the path you captured, never a guess. This part is why each step is where it is.

## Resolve the executable before killing

```bash
# shell: host, root
sudo readlink -f /proc/1235/exe
```

```text
/usr/local/bin/collector2
```

`/proc/PID/exe` is a **magic symlink the kernel maintains**, pointing at the exact inode currently mapped as that process's executable image (`man 5 proc`). It is authoritative in a way no displayed name is:

- `comm` / `argv[0]` can be anything `exec` was handed (Part 1);
- the binary could be a renamed copy of something else, or a symlink;
- the on-disk file may already be **deleted** — `readlink` then shows `/usr/local/bin/collector2 (deleted)`, which is itself a strong signal (a legitimate daemon rarely runs from an unlinked binary).

`readlink -f` canonicalises: it follows every symlink in the chain and returns the final real path, safe to act on.

**Why before the kill:** `/proc/PID/` is a live window into a running task, not a record. The moment the process exits, `/proc/1235/` is gone entirely — `readlink /proc/1235/exe` returns `No such file or directory`. Kill first and the path you needed no longer exists to look up. Graders and real postmortems check specifically for this ordering.

```
  confirmed PID 1235
        │
   readlink -f /proc/1235/exe   ──►  capture  /usr/local/bin/collector2
        │
   kill 1235  (SIGTERM) ─ wait ─ kill -9 1235 if still alive
        │
   rm  /usr/local/bin/collector2      ← the captured path, not a guess
```

## Terminate: the escalation ladder

```bash
sudo kill 1235          # SIGTERM — a request; the process can catch it and clean up
sleep 2
ps -p 1235              # still listed?
sudo kill -9 1235       # SIGKILL — the kernel enforces it; no handler can block or delay it
```

Start with `SIGTERM` so a well-behaved process flushes and exits cleanly. Escalate to `SIGKILL` only if it is still alive after a grace period. `kill -9` cannot be caught, blocked, or ignored — but it also gives the process no chance to release resources, so it is the second resort, not the first.

## Remove: the captured path only

```bash
sudo rm /usr/local/bin/collector2
```

Use the string from `readlink -f`, not one reconstructed from the process name. If the real path had differed from the guessed one — realistic for a disguised or self-replacing binary — removing the guess leaves the actual file on disk while the incident looks closed. Capturing `/proc/PID/exe` first is exactly what closes that gap.

## Act only on what you confirmed

If `collector1` and `collector3` produced nothing across an adequate window (Part 2), they stay running, untouched. "End the process" for confirmed offenders is not licence to kill everything nearby "to be safe" — that destroys evidence and takes down services that were never involved, and is treated as a real error, not caution.

> [!WARNING]
> - **Killing before resolving `/proc/PID/exe`.** `/proc/PID/` vanishes with the process; the path is then unrecoverable.
> - **`rm`-ing a path guessed from the process name.** Name ≠ backing file. Remove the canonicalised `readlink -f` result.
> - **Leading with `kill -9`.** No clean shutdown, possible corruption. `SIGTERM`, wait, then `SIGKILL`.
> - **Sweeping up unconfirmed neighbours.** Only processes with observed evidence get terminated.

> *Resolve `readlink -f /proc/PID/exe` before killing (the `/proc` entry disappears with the process), escalate `SIGTERM`→`SIGKILL`, then `rm` the captured canonical path — and leave every process you did not confirm alone.*

## Reference

- `man 5 proc` — `/proc/PID/exe` as a kernel-maintained symlink, and the `(deleted)` suffix meaning.
- `man 1 kill` / `man 7 signal` — `SIGTERM` vs `SIGKILL`: catchable vs kernel-enforced.
- `man 1 readlink` — `-f` canonicalisation versus a bare symlink read.
