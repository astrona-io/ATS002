# Docker Container Lifecycle Lab

Welcome to a docking bay mission, astronaut. Two nginx pods are docked to this ship, and a third one is waiting for clearance.

Your job is to stop one pod cleanly, read two exact facts out of the other pod's record with `docker inspect --format`, and dock a new pod with a memory limit and a port mapping.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-020/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-022
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-020/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-022
```
