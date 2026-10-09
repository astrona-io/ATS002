# System Disaster Recovery Integration Capstone Lab

Welcome to a bad night on call, astronaut. You have just been paged, and two things are wrong on this host at once. A secondary disk's partition table is gone, and the ship's own launch checklist, `/boot/grub/grub.cfg`, is missing before the next scheduled reboot.

Both problems are set up safely. The secondary disk (serial `lab080-vdc`) is a real 2 GB GPT disk with two ext4 partitions; the setup script backed up its table to `/root/vdc-ptable-backup.bin` and then wiped it. On the main disk, only `grub.cfg` was removed: the running kernel and GRUB's installed boot code were not touched, so SSH keeps working and only the next reboot would fail.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/capstone/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-080
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/capstone/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-080
```
