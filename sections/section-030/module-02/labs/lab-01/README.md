# libvirt Virtual Machine Lifecycle Lab

Welcome to a hangar mission, astronaut. This training ship is a hangar: libvirt is running, its `default` network is up, and a disk image for a new smaller ship, `inventory-db`, is waiting in `/var/lib/libvirt/images/`.

Your job is to file a blueprint for that ship with the exact size and network you are given, register it so it survives a stop, and make it launch whenever the hangar opens. Then practise landing it gently and cutting its engines.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-032
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-030/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-032
```
