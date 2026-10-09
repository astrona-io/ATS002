# Wrap-Up: Mission Debrief

Well flown, astronaut. You clipped a flight recorder onto a crew member, caught the one forbidden request, and cleaned up without losing the evidence. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about proving which process misbehaves, and then removing it safely.

**From [From A Name To The Right PIDs](./course-01-from-a-name-to-the-right-pids.md):**

- A process has three names: `comm` (at most 15 characters, often the interpreter), `argv[0]`, and the program path in `/proc/PID/exe`.
- `pgrep -a -f <pattern>` matches the full command line and prints it, so you can read each hit.
- Check owner and elapsed time with `ps -o pid,user,etimes,cmd` before you act.

**From [Attaching And Filtering The Syscall Stream](./course-02-attaching-and-filtering.md):**

- `strace -p PID` attaches with `ptrace`. The kernel stops the target at every system call, so it runs slower while traced.
- With `kernel.yama.ptrace_scope` at `1`, you need `sudo` to attach to a process you did not start.
- `-e trace=kill` or a class such as `%signal` filters the recording. `-f` follows threads, and `-tt` adds time stamps.
- A "not seen" result only counts if the watch lasts longer than the suspected interval.

**From [From Confirmed Process To Safe Cleanup](./course-03-from-confirmed-process-to-safe-cleanup.md):**

- `readlink -f /proc/PID/exe` gives the real program file. Run it before the kill, because `/proc/PID/` disappears with the process.
- Send `SIGTERM` first, wait, and use `SIGKILL` (`kill -9`) only if the process is still alive.
- Remove only the captured path, and leave every unconfirmed process running.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Process Forensics with strace Lab](./labs/lab-01/README.md) | From Confirmed Process To Safe Cleanup | caught the one process that calls `kill()`, ended it, removed its program file, and left the others running |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why does <code>pgrep collector1</code> find nothing when the process is <code>python3 /opt/collectors/collector1.py</code>?</summary>

Without `-f`, `pgrep` only checks `comm`, which is `python3`. `pgrep -f collector1` checks the full command line, where `collector1` appears.
</details>

<details>
<summary>2. What does <code>-a</code> add to <code>pgrep</code>, and why does it matter?</summary>

It prints the full command line next to each PID. You can then read each hit and drop unrelated processes that happen to contain the same word.
</details>

<details>
<summary>3. Why does the traced process run slower while <code>strace</code> is attached?</summary>

`strace` uses `ptrace`. The kernel stops the process at every system call entry and exit and hands control to `strace`, which adds two switches per call.
</details>

<details>
<summary>4. You watched a process for 20 seconds and saw no <code>kill()</code>. Is it innocent?</summary>

Not if the suspected action runs less often than every 20 seconds. The watch must last longer than the interval before "not seen" means anything.
</details>

<details>
<summary>5. Why must you run <code>readlink -f /proc/PID/exe</code> before the kill?</summary>

`/proc/PID/` exists only while the process runs. Once it ends, the kernel removes the folder, and the path to the real program file can no longer be read there.
</details>

<details>
<summary>6. Why start with <code>kill</code> (<code>SIGTERM</code>) and not <code>kill -9</code>?</summary>

`SIGTERM` lets the process save its work and exit cleanly. `SIGKILL` cannot be caught and gives no chance to tidy up, so it is the second choice.
</details>

<details>
<summary>7. You confirmed one guilty process out of three. What happens to the other two?</summary>

Nothing. They stay running and their files stay on disk. Killing unconfirmed processes destroys evidence and takes down services that were never involved.
</details>

## Clean up the playground

Your playground and any mission each run a virtual machine on your computer. When you are done with this module, remove what is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy strace-process-forensics
```

If the mission is still running, remove it too:

```sh
astrona destroy ats-002-lab-015
```

> *Confirm with evidence, record the real path, then end only the guilty process.*
