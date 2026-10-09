# DNF Package Information Lookup Lab

Welcome aboard, astronaut. This is a research mission: you will look up packages with `dnf search`, `dnf info`, `dnf provides` and `dnf list installed`, without installing, removing or upgrading anything.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it, with EPEL enabled and a fresh repository catalogue. All the work happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

Because the mission is read-only, you save your findings into a few small answer files inside the container (`question.md` gives the exact paths). That gives the grader a concrete record to check.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-04/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-064
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-04/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-064
```
