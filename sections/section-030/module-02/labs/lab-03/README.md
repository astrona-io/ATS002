# Reconfigure a Persistent Domain Lab

Welcome to a refit mission, astronaut. The smaller ship `web-db` has a registered blueprint in this hangar, but it was built too small: 512 MiB of memory and 1 virtual CPU. It is parked, shut off.

Your job is to change its blueprint so it gets 2048 MiB and 2 virtual CPUs for good, not just until the next stop, and then launch it. A change made only to the running ship does not count.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-03
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-034
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-030/module-02/labs/lab-03
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-034
```
