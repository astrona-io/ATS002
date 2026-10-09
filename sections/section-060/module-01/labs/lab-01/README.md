# RPM Low-Level Package Management Lab

Welcome aboard, astronaut. A supply crate with no depot behind it has arrived: a standalone `.rpm` file. You will read its label before you open it, load it with `rpm`, answer which crate owns which file, and check its contents against the ledger.

## Where you work

The lab machine runs Ubuntu 24.04, and `rpm` is not Ubuntu's package tool. So the lab starts a real Rocky Linux 9 container named `rpmbox` on it. A container is a sealed pod docked to the ship, with its own tools and its own RPM database. All the work in this lab happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

The package file, `rpm` and the RPM database all live inside `rpmbox`. Commands run on the Ubuntu machine itself do not see any of it.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-061
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-061
```
