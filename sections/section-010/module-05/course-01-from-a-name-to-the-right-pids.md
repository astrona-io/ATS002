# From A Name To The Right PIDs

Astronaut, `strace` is the flight recorder you clip onto one crew member. But it only knows crew badge numbers: it attaches to a numeric **PID** (process ID) and has no idea what a process is called. So your first move is always the same: turn a fuzzy name into an exact, confirmed list of PIDs.

Doing that reliably means knowing the three different "names" a process has, and which one your search tool looks at.

## A process has three names, and they can all differ

Every process carries three names, kept in three different places. This table shows where each one lives and who sets it:

| Name | Where it lives | Length | Set by |
|---|---|---|---|
| `comm` | `/proc/PID/comm`, `ps` "COMMAND" | **15 chars max** | the executable's basename, or `prctl(PR_SET_NAME)` |
| `argv[0]` | `/proc/PID/cmdline` (first field) | unbounded | whatever `exec` was called with |
| executable path | `/proc/PID/exe` (symlink) | — | the kernel, from the `exec`'d inode |

For a script, these three names are very different. Take `python3 /opt/collectors/collector1.py`. Its `comm` is `python3` (and would be cut to 15 characters anyway), its `argv[0]` is `python3`, and the word `collector1` only appears later in the command line. A tool that looks only at `comm` will never find "collector1".

## Find the PIDs with `pgrep -a -f`

`pgrep` searches the running processes and prints the PIDs that match. Two options make it reliable for this job.

### A real search

<!-- astrona:playground:renew -->

Search for every process with `collector` in its command line:

```bash
# shell: any host, unprivileged
pgrep -a -f collector
```

```text
1234 /usr/local/bin/collector1
1235 /usr/local/bin/collector2
1236 /usr/local/bin/collector3
```

### What the two options do

- **`-f`** matches the pattern against the **full `/proc/PID/cmdline`**, not just `comm`. This is what finds `collector1` inside `python3 /opt/collectors/collector1.py`. Without `-f`, `pgrep collector1` checks `comm` only and finds nothing for a script.
- **`-a`** prints the full command line next to each PID. Now you can **read each hit and check that you caught the right processes**, and not an unrelated `log-collector-helper` that also contains the word.

The pattern is an extended regular expression (a search pattern), and it can match anywhere in the line. If the loose match finds too much, tighten it, for example `pgrep -a -f '^/usr/local/bin/collector[0-9]+$'`.

## Try it: from a name to confirmed PIDs

Your playground runs three demo services: `collector1`, `collector2` and `collector3`. Find them, then look closer at `collector2`:

```bash
pgrep -a -f collector
ps -o pid,user,etimes,cmd -p "$(pgrep -f collector2)"
tr '\0' ' ' < /proc/"$(pgrep -f collector2)"/cmdline; echo
```

Expect something like:

```text
731 /bin/bash /usr/local/bin/collector1
733 /bin/bash /usr/local/bin/collector2
735 /bin/bash /usr/local/bin/collector3
733 root      612 /bin/bash /usr/local/bin/collector2
/bin/bash /usr/local/bin/collector2
```

`-f` matched the full command line, so it found `collector2` even though its `comm` is `bash`: these are shell scripts. Your PIDs and `etimes` values will differ. What matters is that you now have one specific PID you have checked with your own eyes, not a guess.

## Confirm before you act

A pattern can match more than you meant. Check each candidate before you attach a tracer.

### Check the owner, the age and the exact command line

```bash
ps -o pid,user,etimes,cmd -p 1234,1235,1236     # who owns them, how long they've run
cat /proc/1235/cmdline | tr '\0' ' '; echo      # the exact argv, NUL-separated
```

The PIDs 1234, 1235 and 1236 are examples. In your playground, use the PIDs that `pgrep -a -f collector` printed.

`etimes` is the elapsed time in seconds since the process started. It helps: a process that started ten seconds ago is unlikely to be the one that has been misbehaving "for hours". You want a short, clear list of PIDs you are sure about before you attach anything.

The manual pages `man pgrep`, `man 5 proc` and `man 1 ps` explain these options and files in full.

> *A process's `comm` (at most 15 characters, often the interpreter), its `argv[0]` and its executable path can all differ. `pgrep -a -f <pattern>` matches the full command line and prints it, so you can confirm the exact PIDs before you attach.*

## Common pitfalls

> [!WARNING]
> - **`pgrep name` without `-f` for a script.** `comm` is the interpreter (`python3`), cut to 15 characters. Use `-f` to match the full command line.
> - **Trusting the match blindly.** `-a` is there so you *read* each hit. `collector` also matches `collectord`, `my-collector-shim` and so on.
> - **Attaching to a PID you have not confirmed.** Check the owner and the elapsed time first. Tracing, or later killing, the wrong process is the expensive mistake.
