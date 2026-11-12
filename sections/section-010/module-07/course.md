# Process Inspection And Control

Astronaut, every program running on your ship is a crew member doing one job. Sooner or later one of them misbehaves: it burns all the power, it ignores an order, or it will not leave. This module teaches you to find the right crew member, read what state they are in, send them the right order, and change how much of the reactor's time they get.

You work with `ps`, `pgrep`, `kill`, `pkill`, `nice` and `renice`. Each one has a trap that costs time on the exam, so every part gives you a real process to practise on.

## Learning objectives

After this module you can:

- List processes with `ps aux` and `ps -eo`, and sort them by CPU or memory.
- Find a process by name or by owner with `pgrep`, and read its state letter (`R`, `S`, `D`, `T` or `Z`).
- Read a process's state and parent in `/proc/<pid>/status`.
- Send a signal with `kill`, `pkill` and `killall`, and explain the difference between `SIGTERM`, `SIGKILL`, `SIGHUP`, `SIGSTOP` and `SIGCONT`.
- Explain why a process can ignore `SIGTERM` but never `SIGKILL`.
- Start a command with `nice`, change a running one with `renice`, and read the result with `ps -o ni`.
- Use `jobs`, `bg`, `fg` and `nohup` for work started from your own shell.

## Before you start

Check that you have the knowledge and the tools this module expects.

### What you should already know

- **How to work in a shell.** You can type commands and use `sudo`.
- **What a process is.** A process is one running program, a crew member doing one job.

You do not need any earlier experience with signals or priorities.

### What is in your playground

Your playground is one Ubuntu 24.04 training ship with a crew account named `crew`. Three crew members are already working: a script `cpuburn.sh` that uses a whole CPU, a script `stubborn.sh` that ignores the polite order to stop, and a long sleeper called `crew-sleeper`. All three run as the user `crew`.

Start the playground, then open a terminal on it with `astrona ssh astro-process-control-bay`. When you are finished, remove it with `astrona destroy process-control-bay`.

<!-- astrona:playground -->

Every command block says which rights it expects, so you can also follow the text on any Ubuntu 24.04 machine.

## How this module is laid out

1. [Finding And Reading Processes](./course-01-finding-and-reading-processes.md): `ps`, `pgrep`, sorting by CPU, the state letters, and what `/proc/<pid>/status` says.
2. [Signals And Stopping Processes](./course-02-signals-and-stopping-processes.md): `kill`, `pkill` and `killall`, the five signals that matter, and why `SIGTERM` can fail.
3. [Priority And Jobs](./course-03-priority-and-jobs.md): `nice`, `renice`, and the foreground, background and `nohup` tools of your shell.
   - Mission: [Process Inspection And Control Lab](./labs/lab-01/question.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

On a busy machine you must act on the right process, fast, and leave the others alone. Stopping the wrong process or using a signal that does nothing both fail without a clear error. The exam asks you to find a process, stop it in the right way, and change its priority, then check the result.

<!-- curriculum-practice -->
## Practice and assessment

- [Process Inspection And Control Lab](labs/lab-01/question.md): Stop a process that ignores the default signal by sending the signal it cannot ignore; Change the niceness of a running process without ending it; Find a process ID with pgrep and record it in a file.
- [Kernel, Process, Module & Device Runtime Management Capstone Lab](../capstone/labs/lab-01/question.md): Record live kernel state and raise kernel.pid_max live and persistently; Load, parameterise, persist and blacklist kernel modules, and name a disk with a udev rule; Confirm a hung service with strace before you stop it.
