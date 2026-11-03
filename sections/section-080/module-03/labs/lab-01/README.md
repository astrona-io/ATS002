# Partition Table Backup & Recovery Lab

Welcome to a safety drill, astronaut. Your training ship has a second, disposable 2 GB disk (serial `lab083-vdc`) with a GPT partition table, two ext4 partitions and a `marker.txt` file in each. Risky partitioning work is about to start on it.

You take a copy of the deck plan first, check it, wipe the table on purpose, restore it, and prove that both filesystems and their files survived. Nothing here needs to be faked: it is the real procedure on a real secondary disk, and your ship stays reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-03/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-083
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-03/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-083
```
