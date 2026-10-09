# Section 080: System Disaster Recovery

Astronaut, this section is about the night your ship will not cooperate. One bad line in `/etc/fstab` stops the launch cold. The root password is lost and no other account can borrow the captain's authority. A disk's partition table is wiped. The launch computer, GRUB, has lost its checklist. None of these means the data is gone. Each one needs a calm, repeatable procedure to get back in, and the discipline to prove the fix works before you trust a reboot to it.

**Exam topics covered:** recovering from boot, operating system, filesystem and disk failures.

**How this section runs.** On a real server, some of these repairs happen at a physical console: you interrupt the GRUB menu or boot rescue media on a machine that has stopped answering. The grader reaches your training ship only over SSH, so it cannot type into a boot menu or rescue a ship that will not start. So every mission keeps your ship healthy and reachable, and stages the broken part safely: on a small, disposable second disk, or (for GRUB) as a missing `grub.cfg` that would only break the next reboot. You run the same commands in the same order as the real repair. The pages that teach `rd.break`, `init=/bin/bash` and the `grub>` prompt are worked walkthroughs, and they say so plainly.

---

## What You Will Master

- **chroot repair:** mounting a broken system's root filesystem from outside, bind-mounting a set of tools plus `/dev`, `/proc` and `/sys`, stepping in with `chroot`, fixing a bad `/etc/fstab` line, and proving it with `mount -a` before any reboot.
- **Password recovery without rescue media:** interrupting GRUB for one boot with `rd.break` or `init=/bin/bash`, and resetting a lost root password, by `passwd` or by writing a hash into `/etc/shadow`.
- **Partition table backup and restore:** backing up a GPT table with `sgdisk --backup`, checking the backup, restoring it after a wipe, and checking the partition table and the filesystems as two separate layers.
- **GRUB reinstallation:** telling a broken GRUB (a bare `grub>` prompt) from a failing menu entry, reinstalling GRUB's boot code with `grub-install`, and writing a fresh `grub.cfg` with `update-grub`.

---

## Modules In This Section

Work through the modules in this order. Each part teaches one idea. A mission (a graded lab) comes right after the part it practises, and the last page of each module is a wrap-up. The capstone at the end uses several skills at once.

### [Root-Filesystem Repair via chroot](module-01/course.md)

4 parts and 2 missions:

1. [Why A Bad fstab Stops The Boot](module-01/course-01-why-it-wont-boot-and-reaching-a-shell.md)
2. [Mount The Broken Root And Get The Tools In](module-01/course-02-mount-and-get-tools-in.md)
3. [Chroot In And Fix The Line](module-01/course-03-chroot-in-and-fix-the-line.md)
4. [Prove The Fix And Unmount](module-01/course-04-prove-the-fix-and-unmount.md)
   - Mission: [Root-Filesystem Repair via chroot Lab](module-01/labs/lab-01/README.md)
   - Mission: [chroot Repair: Wrong fstab Filesystem Type Lab](module-01/labs/lab-02/README.md)
5. [Wrap-Up: Mission Debrief](module-01/course-05-wrap-up.md)

### [Password Reset & Single-User Recovery](module-02/course.md)

2 parts and 1 mission:

1. [Two Doors: rd.break And init=/bin/bash](module-02/course-01-two-doors-rd-break-and-init.md)
2. [The chroot Equivalent And Editing /etc/shadow](module-02/course-02-chroot-equivalent-and-shadow-edit.md)
   - Mission: [Password Reset & Single-User Recovery Lab](module-02/labs/lab-01/README.md)
3. [Wrap-Up: Mission Debrief](module-02/course-03-wrap-up.md)

### [Partition Table Backup & Recovery](module-03/course.md)

3 parts and 1 mission:

1. [Two Layers And The Target Disk](module-03/course-01-two-layers-and-identifying-the-disk.md)
2. [Back Up And Verify The Partition Table](module-03/course-02-backup-and-verify.md)
3. [Wipe, Restore And Verify Both Layers](module-03/course-03-simulate-restore-verify.md)
   - Mission: [Partition Table Backup & Recovery Lab](module-03/labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](module-03/course-04-wrap-up.md)

### [GRUB Corruption Recovery](module-04/course.md)

3 parts and 1 mission:

1. [Two Repairs And Reading The Symptom](module-04/course-01-two-repairs-and-the-symptom.md)
2. [The One-Boot Rescue From grub>](module-04/course-02-manual-rescue-from-grub.md)
3. [The Durable Repair: Reinstall And Regenerate](module-04/course-03-durable-repair.md)
   - Mission: [GRUB Corruption Recovery Lab](module-04/labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](module-04/course-04-wrap-up.md)

### Knowledge check

Before the capstone, test your reasoning with the [Section 080 Knowledge Check](./quiz.md).

### Capstone

Your final mission for this section: **[System Disaster Recovery Integration Capstone Lab](capstone/labs/lab-01/README.md)**. You have been paged: restore a secondary disk's partition table from a backup already on file and prove its filesystems survived, then reinstall GRUB and write a fresh `grub.cfg` on the main disk before the next reboot.

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/capstone/labs/lab-01
astrona ssh ats-002-lab-080
astrona submit -c sections/section-080/capstone/labs/lab-01
astrona destroy ats-002-lab-080
```
