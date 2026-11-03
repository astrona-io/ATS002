# Kernel, Process, Module & Device Runtime Management Capstone Lab

Astronaut, this is the final mission of the section. One training ship, an edge telemetry host, has a whole night of problems waiting for you at once: a kernel state to record, a crew badge limit (`kernel.pid_max`) that is too low, two reactor parts (kernel modules) to fit or ban, a new cargo bay (disk) with no stable name, and a hung crew member (`telemetry-agent`) to diagnose with `strace` and stop.

Each problem uses a skill from this section, and the grader checks the real state of the machine for each one.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/capstone/labs/lab-01
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-010
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-010
```
