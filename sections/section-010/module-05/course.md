# Chapter 5: Catching a Process in the Act with strace

Sometimes you're handed a process and told, in effect, "something in here is doing something it shouldn't, and we need proof." You don't have the source code. Even if you did, the binary running right now might not match whatever's checked into a repository somewhere. What you *do* have is a live, running process — and Linux gives you a way to stand right next to it and watch, in real time, every single request it makes to the kernel.

That tool is `strace`. This chapter walks through using it as a live-attach-and-filter investigative instrument, and then through a habit that matters just as much as the tracing itself: never trusting a process's *name* when you're about to delete its backing file.

> Never `rm` a path you guessed. `rm` the path `/proc/PID/exe` actually resolves to — a process's name and its backing binary are not guaranteed to be the same thing.

---

## Part I: From a Name to a PID

`strace -p` attaches to a running process by its numeric PID — it has no concept of a process name. So the first move, always, is turning a name into a list of candidate PIDs:

```bash
pgrep -a -f collector
```

```text
1234 /usr/local/bin/collector1
1235 /usr/local/bin/collector2
1236 /usr/local/bin/collector3
```

Two flags are doing real work here. `-a` prints the full matched command line alongside each PID, so you can visually confirm you've caught the right processes rather than something unrelated with a similar-sounding name. `-f` matches against the *entire* argument list rather than just the truncated process name shown by tools like `ps` — which matters a great deal if a process was actually launched as, say, `python3 /opt/collectors/collector1.py`. Without `-f`, a plain `pgrep collector1` would find nothing at all, because the kernel's own record of the process name (`comm`) would show `python3`, not `collector1`.

---

## Part II: Attaching and Filtering the Noise

`strace -p PID` with no other flags dumps *every* syscall a process makes — file opens, memory calls, network activity, all of it, scrolling past in an unreadable torrent. On a busy process, the one line you actually care about can scroll off-screen before you even notice it happened. The fix is a filter:

```bash
sudo strace -p 1234 -e trace=kill
```

`man strace` documents the `-e trace=` expression in detail — you can name a single syscall, a comma-separated list, or an entire syscall class like `%signal` or `%process`. Here, `-e trace=kill` tells `strace` to report *only* `kill()` syscall entries and suppress absolutely everything else. The terminal stays quiet — until, and unless, the exact syscall you're hunting actually fires.

`sudo` is typically required here, since attaching to another user's process is subject to the kernel's `ptrace` scope restrictions.

---

## Part III: Watching Long Enough

If an alert describes behavior as "periodic," that word carries real weight: the syscall you're hunting doesn't necessarily happen the instant you attach. A single glance is not evidence of innocence — it might just be unlucky timing relative to whatever interval the process actually runs on.

You can watch multiple candidates in parallel rather than serializing the wait:

```bash
sudo strace -p 1234 -e trace=kill &
sudo strace -p 1235 -e trace=kill &
sudo strace -p 1236 -e trace=kill &
wait
```

When a match occurs, `strace` prints a line directly attributable to whichever session produced it:

```text
kill(4592, SIGTERM)                    = 0
```

That process is now confirmed, with hard evidence, rather than suspected. A process that produces nothing after a genuinely adequate observation window — one that comfortably spans the suspected interval — is presumed clean. If you're unsure how long "long enough" actually is, corroborating evidence like a cron entry, a systemd timer, or an application log can hint at the real cadence.

---

## Part IV: The Name Is Not the Path

Say `collector2` (PID 1235) is the one caught calling `kill()`. Before you touch anything else, resolve its real, on-disk executable — and do this *before* the process is terminated, because the information disappears the instant it isn't:

```bash
sudo readlink -f /proc/1235/exe
```

```text
/usr/local/bin/collector2
```

`/proc/PID/exe` is a magic symlink the kernel itself maintains, pointing at the exact inode currently mapped as that process's executable image. `man 5 proc` confirms this directly. It is authoritative in a way a process's displayed name never is — a process could be a symlink, a renamed copy of some other binary, or a script whose `comm` field shows the interpreter (`python3`) rather than the script file itself. `readlink -f` additionally canonicalizes the result, resolving every symlink in the chain so you end up with a real, final path you can trust enough to act on.

The moment a process is killed, `/proc/PID/` ceases to exist entirely — it's a live, per-process view into the kernel, not a historical record. If you kill first and try to check the executable path second, there is nothing left to check. This ordering is not a minor style preference; it is the one detail a grader — or a real incident postmortem — is most likely to specifically check for.

---

## Part V: Terminate, Then Remove — In That Order

Once the real path is captured, terminate the confirmed process using the standard escalation ladder:

```bash
sudo kill 1235
sleep 2
ps -p 1235
```

A bare `kill` sends `SIGTERM` — a request the process can catch and clean up after. If it's still alive a couple of seconds later:

```bash
sudo kill -9 1235
```

`-9` delivers `SIGKILL`, which the kernel enforces unconditionally; the process cannot install a handler to intercept or ignore it. Only once the process is confirmed gone do you remove the file, using the exact path you captured earlier — not a path reconstructed from memory or guessed from the process's name:

```bash
sudo rm /usr/local/bin/collector2
```

If the resolved path had turned out to differ from the guessed one — a real possibility with disguised or self-replacing malicious binaries — removing a guessed path would leave the actual offending file untouched on disk while creating a false sense that the incident was closed. That gap is precisely what capturing `/proc/PID/exe` first is designed to close.

Finally: act only on processes you've actually confirmed. If `collector1` and `collector3` show no `kill()` calls across an adequate observation window, they stay running, untouched. A task that asks you to "end the process" for confirmed offenders is not an invitation to terminate everything nearby "to be safe" — that's treated as a real mistake, not a cautious one, because it destroys evidence and disrupts services that were never actually part of the problem.

---

## Self-Check and Verification

1. **Filtering**: What flag turns an unreadable full syscall trace into a targeted watch for one syscall? *(Answer: `-e trace=<syscall>`.)*
2. **Ordering matters**: Why must you resolve `/proc/PID/exe` *before* killing the process, not after? *(Answer: `/proc/PID/` disappears the instant the process is gone — there's nothing left to resolve afterward.)*
3. **Name vs. reality**: Why can't you trust a process's displayed name as its actual on-disk file path? *(Answer: the displayed name is just `argv[0]`/`comm` — a process can be a renamed copy, a symlink, or a script running under an interpreter, none of which necessarily match the real backing file.)*
4. **Scope of action**: If only one of three suspected processes is confirmed guilty, what happens to the other two? *(Answer: nothing — they're left running untouched; only confirmed processes are terminated and removed.)*

You now have the complete live-diagnosis workflow this section has been building toward: read state precisely (Chapter 1), understand the ceilings that govern how many processes can even exist (Chapter 2), manage what code the kernel is running (Chapter 3), give hardware names you can trust (Chapter 4), and now, catch a running process doing something it shouldn't. The capstone lab ahead asks you to bring all five together in one incident.
