# LVM Recovery Lab

Welcome, astronaut. The great hold `cargo_vg` on your training ship has vanished. `pvs`, `vgs` and `lvs` show nothing, but the spare disk (serial `lab088-pv001`) still holds a deck of files you must not lose. Someone wiped the start of the disk, which held the LVM label.

You rebuild the label and the hold from LVM's own text backup, switch the deck on, mount it and prove the files are still there. The repair runs on the spare disk only, so your ship stays reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-07/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-088
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-07/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-088
```
