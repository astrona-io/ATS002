# Process Limits: Diagnose the Single Clamp (ulimit -u) Lab

Welcome to a diagnosis mission, astronaut. A batch job on this training ship cannot start enough processes. Three ceilings could be the cause, but only one of them is really too low here. The other two are already generous.

Your job is to inspect all three, find the one real limit, and raise **only** that one so the change lasts. Raising the other two by reflex counts as a wrong diagnosis.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-02/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-012b
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-02/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-012b
```
