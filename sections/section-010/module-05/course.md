# Catching a Process in the Act with strace

Astronaut, you are told that one crew member on your ship is misbehaving, and you need proof. You have no source code, and the program running now may not match anything in a repository. What you do have is a live process. Linux lets you stand next to it and record every request it makes to the reactor core, the kernel.

The tool for that is `strace`: the flight recorder you clip onto one crew member. This module teaches you to attach it to a running process and filter its recording down to one request. It also teaches the discipline that matters as much as the recording: find the process's real program file on disk before you kill it, and never remove a path you guessed from its name.

## Learning objectives

After this module you can:

- **Turn** a fuzzy process name into a confirmed PID list with `pgrep -a -f`, and explain why `-f` is needed for a script.
- **Explain** what `strace` does to attach (`ptrace`, a stop at every system call) and why it slows the target.
- **Filter** a trace to one system call or a class of system calls, and follow child threads with `-f`.
- **Explain** why a short watch cannot prove that a periodic action never happens.
- **Resolve** a process's real program file with `readlink -f /proc/PID/exe`, and explain why this must happen before the kill.
- **Terminate** a process with the `SIGTERM` then `SIGKILL` escalation, and remove only the captured path.
- **Limit** your action to processes you have confirmed, and leave unconfirmed neighbours running.

## Before you start

Check what this module expects you to know, and what is waiting in your playground.

### What you should already know

- **A Linux shell and `sudo`.** You can type commands and borrow the captain's authority for the ones that change the system.
- **Signals.** `SIGTERM` asks a process to finish up and leave. `SIGKILL` ends it at once.
- **`/proc/PID/`.** The kernel shows one folder per running process under `/proc`, named after its process ID (PID).
- **Kernel parameters.** Kernel settings such as `kernel.yama.ptrace_scope` can be read under `/proc/sys`.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine running three demo services, **`collector1`, `collector2` and `collector3`**. `collector2` makes a `kill()` system call about every 10 seconds, so `strace -e trace=kill` has something real to catch. `strace` and the `procps` tools (`pgrep`, `ps`) are installed.

Start the playground, then open a terminal on it with `astrona ssh astro-strace-process-forensics`. Every command block also says which shell and which privileges it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [From A Name To The Right PIDs](./course-01-from-a-name-to-the-right-pids.md): the three names a process has (`comm`, `argv[0]` and the program path), why they differ for scripts, and `pgrep -a -f` to confirm the exact PIDs.
2. [Attaching And Filtering The Syscall Stream](./course-02-attaching-and-filtering.md): what `ptrace` attachment does and what it costs, `kernel.yama.ptrace_scope` and why you need `sudo`, `-e trace=` filters and `%` classes, `-f`, and watching long enough.
3. [From Confirmed Process To Safe Cleanup](./course-03-from-confirmed-process-to-safe-cleanup.md): `/proc/PID/exe` as the kernel's own pointer to the real program file, why you resolve it before killing, the `SIGTERM` to `SIGKILL` ladder, and removing only the captured path.
   - Mission: [Process Forensics with strace Lab](./labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

On the exam and on a real server, the hard part is rarely typing `kill`. It is being sure which process to kill, proving it with evidence, and cleaning up without destroying that evidence or taking down innocent services. This module trains that order until it becomes a habit.
