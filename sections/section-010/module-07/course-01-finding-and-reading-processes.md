# Finding And Reading Processes

Astronaut, before you give an order to a crew member, you must know who they are and what they are doing. This part shows how to list the crew, find one by name, and read their state.

## Listing the crew with ps

`ps` is the crew roster. It prints one line for each process it is asked about.

<!-- astrona:playground:renew -->

Here is a real example. List every process with the owner, the process ID (PID, the crew badge number), the CPU share and the command:

```bash
# shell: any user
ps aux | head -5
```

The first line holds the column names. Each other line is one process. `a` means "processes of all users", `u` adds the owner and usage columns, and `x` adds processes that have no terminal.

### Choosing your own columns

`ps aux` gives a fixed set. When you need exact columns, use `-e` (every process) with `-o` (output columns):

```bash
# shell: any user
ps -eo pid,ppid,user,stat,ni,pcpu,comm | head -5
```

Each name picks one column: `pid` is the badge number, `ppid` is the badge number of the parent, `stat` is the state, `ni` is the niceness (the priority setting, covered in a later part) and `pcpu` is the CPU share. Add `=` after a name, for example `-o pid=`, to print the value with no heading. That is the form to use in scripts.

### Sorting by CPU or memory

`--sort` takes a column name. A minus sign means "largest first":

```bash
# shell: any user
ps -eo pid,user,pcpu,comm --sort=-pcpu | head -5
```

The process at the top of this list is using the most CPU. Use `--sort=-pmem` for memory. `top -b -n 1 | head -15` prints one snapshot of the live `top` screen and then leaves, which is useful in scripts.

## Finding a process with pgrep

Reading a long list is slow. `pgrep` searches the roster for you and prints only PIDs.

### See it in your playground

In your playground, find the crew member that sleeps:

```bash
# shell: any user
pgrep -a crew-sleeper
```

`-a` prints the whole command next to the PID. Without it you get only the number. By default `pgrep` matches the process name only. Add `-f` to match the full command line, and `-u crew` to match only processes that belong to the user `crew`:

```bash
# shell: any user
pgrep -af stubborn
pgrep -u crew
```

The first command finds the `stubborn.sh` script, which a name-only match would miss because its process name is the script name. The second lists every PID owned by `crew`.

## Reading the state letter

The `stat` column holds one letter that says what the process is doing right now.

| Letter | Meaning |
| --- | --- |
| `R` | Running, or ready to run |
| `S` | Sleeping, waiting for something, and can be woken |
| `D` | Sleeping and cannot be interrupted, usually waiting for a disk |
| `T` | Stopped by a signal |
| `Z` | Zombie: the process has finished but its parent has not collected the result |

Extra characters may follow the letter. For example `<` means high priority, `N` means low priority and `+` means it is in the foreground of a terminal.

### Reading /proc/<pid>/status

The kernel keeps a live file for each process. It is the crew member's record in the reactor core's files:

```bash
# shell: any user
grep -E '^(Name|State|PPid)' /proc/$(pgrep -f crew-sleeper | head -1)/status
```

`State:` repeats the state letter with a word. `PPid:` is the parent's badge number.

### A zombie has nothing left to kill

A zombie is already finished. Only its entry in the process table stays, until the parent reads its exit result. `kill -9` on it does nothing. Find the parent and fix that instead:

```bash
# shell: any user
ps -o ppid= -p <PID>
```

Replace `<PID>` with the zombie's number. If the parent cannot be fixed, ending the parent lets the system's first process collect the zombie.

## Common pitfalls

> [!WARNING]
> - **Matching too much with a short name.** `pgrep sleep` also finds other programs with `sleep` in the name. Check with `pgrep -a` before you act on the numbers.
> - **Forgetting `-f` for scripts.** A script's process name is the script file name, and its full command line holds the path.
> - **Trying to kill a zombie.** It is already gone. Deal with its parent.

*`ps` lists, `pgrep` searches, the state letter tells what a process is doing, and a zombie needs its parent fixed.*
