# RPM/DNF Package Management Capstone Lab

Welcome to the capstone, astronaut. This mission puts every skill of the section into one incident. A ship was halfway through being set up when something killed a process overnight. You have to sort out what actually broke and what is simply waiting for you: repair the package database, install a standalone package and fit the ship out with a build toolchain.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it. All the work happens **inside that container**, not on the Ubuntu machine itself.

Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

The lab's setup first built a real standalone `.rpm` with `rpmbuild` and placed it in the container. After that, it really damaged the container's `sqlite` RPM database file. Neither is faked: `rpm -qa` fails until you repair the database.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-060
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-060
```
