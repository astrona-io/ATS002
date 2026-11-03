# Software RAID Recovery Lab

Welcome, astronaut. The mirrored array `/dev/md/cargo` on your training ship has lost one of its two disks. It still runs on the other one, but it has no redundancy, and a third, blank disk waits as the spare.

You replace the failed member with the spare, wait for the rebuild, save the array in `mdadm.conf` and prove the files are still there. The work happens on the spare disks only, so your ship stays reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-08/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-089
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-08/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-089
```
