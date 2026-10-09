# Stable Device Naming with udev Lab

Welcome to a dock master mission, astronaut. A backup script on this training ship names its backup disk by a device letter, and device letters change with the order the disks arrive. Your job is to write a udev rule that recognises the disk by its serial number, its hull serial, and gives the disk and its partition names that never change.

The ship is an Ubuntu 24.04 virtual machine with an extra 1 GB disk that already holds one ext4 partition.

## Launching the Lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-04/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-014
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-010/module-04/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-014
```
