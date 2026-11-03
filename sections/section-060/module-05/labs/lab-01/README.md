# DNF Package Groups Lab

Welcome aboard, astronaut. You will find out which package groups this ship's repositories publish, read the real mandatory, default and optional members of one group before installing it, install and confirm it, and then remove it as a unit. Along the way you see for yourself which packages a group removal takes and which it leaves.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it. All the work happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

The lab's setup has also installed `automake` inside `rpmbox` on its own, outside any group, before you touch `"Development Tools"`. That is on purpose: it lets you see, for real, which packages a later `dnf group remove` does and does not remove.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-05/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-065
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-05/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-065
```
