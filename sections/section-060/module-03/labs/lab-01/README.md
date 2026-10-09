# DNF Basic Package Operations Lab

Welcome aboard, astronaut. It is maintenance window time on this ship. You will check and apply upgrades, install and remove packages, clean up leftover dependencies, and use `dnf history` to undo a transaction that pulled in more than anyone wanted.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it, with the EPEL repository already enabled so that `fail2ban` can be installed. All the work happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-03/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-063
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-03/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-063
```
