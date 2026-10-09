# Transient to Persistent Domain Lab

Welcome to a rescue mission, astronaut. A smaller ship, `metrics-cache`, is flying in this hangar, but it was launched from a blueprint nobody filed: it is a **transient** domain, started with `virsh create`. The moment it lands, or the host reboots, it is gone.

Your job is to file its blueprint while it keeps flying, so it becomes a **persistent** domain, and to make it launch whenever the hangar opens.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-033
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-030/module-02/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-033
```
