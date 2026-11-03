# Filesystem Check & Repair Lab

Welcome, astronaut. A cargo deck on your training ship will not open: the spare disk (serial `lab086-data001`) holds an ext4 filesystem with files you must not lose, but the first record the kernel reads, the primary superblock, has been wiped.

You find a surviving backup superblock, repair the filesystem with it, and prove that the files are still there. The repair runs on the spare disk only, so your ship stays reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-05/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-086
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-05/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-086
```
