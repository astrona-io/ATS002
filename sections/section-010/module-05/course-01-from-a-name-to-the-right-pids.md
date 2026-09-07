# Part 1 — From a name to the right PIDs

> Prerequisite: [module landing page](./course.md). Next: [Part 2 — Attaching and filtering the syscall stream](./course-02-attaching-and-filtering.md).

`strace` attaches by numeric PID and has no concept of a process name. So the first move is always turning a fuzzy name into an exact, confirmed set of PIDs — and doing that reliably means knowing the three different "names" a process has and which one your search tool is matching against.

## A process has three names, and they can all differ

| Name | Where it lives | Length | Set by |
|---|---|---|---|
| `comm` | `/proc/PID/comm`, `ps` "COMMAND" | **15 chars max** | the executable's basename, or `prctl(PR_SET_NAME)` |
| `argv[0]` | `/proc/PID/cmdline` (first field) | unbounded | whatever `exec` was called with |
| executable path | `/proc/PID/exe` (symlink) | — | the kernel, from the `exec`'d inode (Part 3) |

For a script these diverge hard: `python3 /opt/collectors/collector1.py` has `comm` = `python3` (truncated to 15 chars anyway), `argv[0]` = `python3`, and the string `collector1` appears only later in `cmdline`. A tool matching `comm` will never find "collector1".

## `pgrep -a -f`

```bash
# shell: any host, unprivileged
pgrep -a -f collector
```

```text
1234 /usr/local/bin/collector1
1235 /usr/local/bin/collector2
1236 /usr/local/bin/collector3
```

Two flags carry the weight:

- **`-f`** — match the pattern against the **full `/proc/PID/cmdline`**, not just `comm`. This is what finds `collector1` inside `python3 /opt/collectors/collector1.py`. Without `-f`, `pgrep collector1` matches `comm` only and returns nothing for an interpreted script.
- **`-a`** — print the full command line next to each PID, so you can **eyeball that you caught the right processes** and not an unrelated `log-collector-helper` that also contains the substring.

`pgrep` uses an extended regex, unanchored: `pgrep -a -f '^/usr/local/bin/collector[0-9]+$'` tightens it if the loose match is too broad.

> [!TIP]
> **Try it — name to confirmed PIDs.** On the playground host (`astrona ssh astro-strace-process-forensics`):
>
> ```bash
> pgrep -a -f collector
> ps -o pid,user,etimes,cmd -p "$(pgrep -f collector2)"
> tr '\0' ' ' < /proc/"$(pgrep -f collector2)"/cmdline; echo
> ```
>
> Expect something like:
>
> ```text
> 731 /bin/bash /usr/local/bin/collector1
> 733 /bin/bash /usr/local/bin/collector2
> 735 /bin/bash /usr/local/bin/collector3
> 733 root      612 /bin/bash /usr/local/bin/collector2
> /bin/bash /usr/local/bin/collector2
> ```
>
> `-f` matched the full command line, so `collector2` was found even though `comm` is `bash` (these are shell scripts). PIDs and `etimes` vary; the point is you now have one specific PID you have eyeballed, not a guess.

## Confirm before you act

The pattern can over-match. Cross-check each candidate:

```bash
ps -o pid,user,etimes,cmd -p 1234,1235,1236     # who owns them, how long they've run
cat /proc/1235/cmdline | tr '\0' ' '; echo      # the exact argv, NUL-separated
```

`etimes` (elapsed seconds) is useful: a process that started ten seconds ago is unlikely to be the thing that has been misbehaving "for hours". You want a small, explicit list of PIDs you are sure about before attaching a tracer.

> [!WARNING]
> - **`pgrep name` without `-f` for a script.** `comm` is the interpreter (`python3`), truncated to 15 chars. Use `-f` to match the full command line.
> - **Trusting the substring match blindly.** `-a` exists so you *read* each hit. `collector` also matches `collectord`, `my-collector-shim`, etc.
> - **Attaching to a PID you have not confirmed.** Check owner and elapsed time first; tracing or later killing the wrong process is the expensive mistake.

> *A process's `comm` (15-char, often the interpreter), `argv[0]`, and executable path can all differ; `pgrep -a -f <pat>` matches the full command line and prints it so you can confirm the exact PIDs before attaching.*

## Reference

- `man pgrep` — `-f` (full cmdline), `-a` (show it), `-u` (by user), the regex syntax.
- `man 5 proc` — `/proc/PID/comm`, `/proc/PID/cmdline`, `/proc/PID/exe` and how they differ.
- `man 1 ps` — `-o` custom columns (`pid,user,etimes,cmd`) for confirming a candidate.
