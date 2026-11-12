# Software RAID With mdadm

Astronaut, a ship that carries irreplaceable cargo does not trust it to one bay. It keeps the same cargo in two bays at once, so that when one bay is destroyed the other still holds everything. On Linux, software RAID does this job, and its control tool is `mdadm`.

In this module you learn to read the state of an array, spot a failed member, replace it with a spare disk, and make the array survive a reboot.

## Learning objectives

After this module you can:

- Explain what RAID 1 does, and read an array's health in `/proc/mdstat` and with `mdadm --detail`.
- Spot a degraded array and name the failed member.
- Remove a failed member and add a replacement with `mdadm --add`, and watch the rebuild.
- Prove the data survived by mounting the array and reading the files.
- Record the array in `/etc/mdadm/mdadm.conf` so it is assembled again at boot.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **How to mount a filesystem** and list its files.
- **That a disk can be found by its serial number** in `/dev/disk/by-id`, not by a device letter.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with three spare disks and a mirrored array.

- Three spare 1 GB disks with the serials `lab089-raid-a`, `lab089-raid-b` and `lab089-raid-c`. Find them at `/dev/disk/by-id/virtio-<serial>`.
- A RAID 1 array called `cargo`, built from disks `a` and `b`, with an ext4 filesystem and two known files. Disk `c` is blank and kept as the spare.
- `mdadm`, `lsblk` and `blkid`.
- Your own machine stays healthy and reachable; the damaged array lives on the spare disks.

Start the playground, then open a terminal on it with `astrona ssh astro-raid-recovery-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Reading A RAID Array](./course-01-reading-a-raid-array.md): what RAID 1 does, `/proc/mdstat`, `mdadm --detail`, and what a degraded array looks like.
2. [Replace A Failed Member](./course-02-replace-a-failed-member.md): failing and removing a member, adding a spare, watching the rebuild, and saving the array in `mdadm.conf`.
   - Mission: Software RAID Recovery Lab
3. [Summary](./course-03-wrap-up.md)

## Why this matters

A mirrored array keeps running when one disk dies, so nobody notices until the second disk fails too. If you do not know how to read a degraded array and replace the dead member, the mirror becomes a single point of failure. The exam asks you to do the replacement and leave the array healthy.

<!-- curriculum-practice -->
## Practice and assessment

- [Software RAID Recovery Lab](labs/lab-01/question.md): Replace a failed RAID 1 member with a spare disk and wait for the rebuild; Save the array in mdadm.conf and prove the data is intact.
- [System Disaster Recovery Integration Capstone Lab](../capstone/labs/lab-01/question.md): Restore a wiped GPT table from a backup and prove the filesystems are intact; Reinstall GRUB and regenerate grub.cfg on the running machine.
