# Rebuilding a Corrupted RPM Database Lab

Welcome aboard, astronaut. The quartermaster's ledger on this ship, the RPM database, was damaged overnight. You will confirm the damage, make a safe copy, rebuild the ledger and prove that `rpm` and `dnf` both work again.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it. The lab's setup then really damages that container's `sqlite` database file before you connect. All the work in this lab happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

The damage is real, not printed error text: `rpm -qa` inside `rpmbox` fails until you repair it.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-02/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-062
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-02/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-062
```
