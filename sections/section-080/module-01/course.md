# Root-Filesystem Repair via chroot

Astronaut, one wrong line in `/etc/fstab` can stop a whole ship on the launch pad. `/etc/fstab` is the list of cargo decks to attach at launch. If one entry names a deck that does not exist, systemd, the ship's duty officer, waits for it, gives up and drops you into emergency mode. Nothing is damaged. Every file is still where it was. Only the one line that says "attach this, here" is wrong.

You do not reinstall anything to fix it. You step into the broken system's files from outside, use its own tools on its own configuration, fix the one line, and prove the fix before you trust a reboot to it. That is a **chroot repair**, and it is core muscle memory for the exam.

## Learning objectives

After this module you can:

- Explain why a bad `/etc/fstab` entry blocks the boot instead of being skipped.
- Reach a shell on a system that will not boot, through the boot menu or rescue media.
- Identify the target root partition without guessing a device name.
- Build a working chroot: bind-mount a set of tools plus `/dev`, `/proc` and `/sys`, and explain what fails without the last three.
- Correct a bad `/etc/fstab` line by checking every field against `blkid`, and create a missing mount point.
- Prove the fix with `mount -a` inside the chroot before rebooting, and unmount cleanly.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.** You can type commands and run them as root.
- **What mounting a filesystem means**, and that a UUID is a unique ID written inside each filesystem.
- **Basic `sed`.** You have seen `sed -i 's/old/new/' file` replace text in a file.

### What you need

- This module has no playground. The examples in the parts are safe to read on any Ubuntu 24.04 machine. Only run the repair commands against a disk you can afford to lose.
- The missions give you a ready-made training ship. The grader reaches it only over SSH, so it cannot type into a boot menu or rescue a ship that will not start. Instead, each mission adds a second, disposable disk that holds a stand-in "broken system" with its own `/etc/fstab`. Your own ship stays healthy and reachable. Every repair step is the real one; only the target disk is different.

## How this module is laid out

1. [Why A Bad fstab Stops The Boot](./course-01-why-it-wont-boot-and-reaching-a-shell.md): how systemd turns `/etc/fstab` into mounts, why one bad entry ends in emergency mode, and the two ways to reach a shell.
2. [Mount The Broken Root And Get The Tools In](./course-02-mount-and-get-tools-in.md): finding the right partition with `lsblk -f`, mounting it, and bind-mounting a working set of tools plus `/dev`, `/proc` and `/sys`.
3. [Chroot In And Fix The Line](./course-03-chroot-in-and-fix-the-line.md): entering the chroot, reading every field of the bad line against `blkid`, and fixing it.
4. [Prove The Fix And Unmount](./course-04-prove-the-fix-and-unmount.md): `mount -a` and its exit code as the proof before any reboot, and unmounting in reverse order.
   - Mission: Root-Filesystem Repair via chroot Lab
   - Mission: chroot Repair: Wrong fstab Filesystem Type Lab
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md)

## Why this matters

A fstab mistake is one of the most common reasons a server will not come back after a reboot. The fix takes two minutes once you know the steps. Without them, people reinstall systems that only needed one character changed. The habit you build here, "prove it inside the chroot before you reboot", is the same one every other recovery task depends on.
