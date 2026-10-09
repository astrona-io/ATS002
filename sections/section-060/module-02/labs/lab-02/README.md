# RPM Database: Corruption Look-Alike Lab

Welcome aboard, astronaut. On this ship `dnf check` fails loudly, and a colleague is sure the RPM database is corrupt. It is not. A package was left with a missing dependency. Read the errors (they name a package, not the database), rule out corruption and a full disk, and fix the dependency instead of reaching for `rpm --rebuilddb`.

## Where you work

The lab machine runs Ubuntu 24.04, so the lab starts a real Rocky Linux 9 container named `rpmbox` on it. All the work happens **inside that container**. Open a shell inside it with:

```bash
docker exec -it rpmbox bash
```

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-02/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-066
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-060/module-02/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-066
```
