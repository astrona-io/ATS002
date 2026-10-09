# Scheduled Container Recovery Capstone Lab

Welcome to the section capstone, astronaut. A retired pod is still docked to this ship and holds the radio channel its replacement needs.

Your job is to retire the old container, launch its replacement with a memory limit and a port mapping, and give the service account `ops-monitor` a standing order that starts the new container again whenever it stops.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-020
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-020
```
