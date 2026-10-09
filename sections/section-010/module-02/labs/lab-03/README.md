# Process Limits: Diagnose the Single Clamp (TasksMax) Lab

Welcome to a diagnosis mission, astronaut. A service on this training ship hits a hard task ceiling while CPU and memory are idle. The machine-wide pool and the `dataproc` user's limit are already generous. Only one ceiling is really too low.

Your job is to inspect all three, find the real limit, raise **only** that one with a systemd override, and apply it to the running service with `daemon-reload` and a restart.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-03
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-012c
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-02/labs/lab-03
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-012c
```
