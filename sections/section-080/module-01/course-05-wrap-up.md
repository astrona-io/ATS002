# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and both missions in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the chroot repair: reaching a broken system's files from outside, fixing one bad `/etc/fstab` line, and proving the fix before a reboot.

**From [Why A Bad fstab Stops The Boot](./course-01-why-it-wont-boot-and-reaching-a-shell.md):**

- `systemd-fstab-generator` turns each fstab line into a `.mount` unit. A line naming a missing device fails, `local-fs.target` fails, and systemd drops to `emergency.target`.
- Nothing is corrupt. The fix is one line in `/etc/fstab`.
- With a working GRUB menu, a one-boot edit with `systemd.unit=emergency.target` skips the bad mount. With a broken GRUB, rescue media plus a chroot is the way in.
- `nofail` and `x-systemd.device-timeout=` stop an optional mount from blocking the boot.

**From [Mount The Broken Root And Get The Tools In](./course-02-mount-and-get-tools-in.md):**

- Find the target partition with `lsblk -f` and `blkid`, never by guessing a device letter.
- Bind-mount `/usr`, `/bin`, `/sbin`, `/lib` (and `/lib64`) when the target has no tools of its own.
- Bind-mount `/dev`, `/proc` and `/sys`, or tools like `blkid` and `mount` fail in confusing ways.

**From [Chroot In And Fix The Line](./course-03-chroot-in-and-fix-the-line.md):**

- `chroot /mnt/repair /bin/bash` makes `/mnt/repair` the root for that shell. Check `/etc/hostname` to confirm you are inside.
- An fstab line has six fields. Compare field 1 (device) and field 3 (type) against `blkid`.
- Fix only the wrong field, and create the mount point with `mkdir -p` if it is missing.

**From [Prove The Fix And Unmount](./course-04-prove-the-fix-and-unmount.md):**

- `mount -a` followed straight away by `echo $?` is the boot-time check, run on demand. `0` means every line can be mounted.
- Regenerate GRUB or the initramfs only from inside the chroot, and only when they were part of the problem.
- Unmount in reverse order, or use `umount -R /mnt/repair`.

## Your missions

You proved these skills in two graded missions, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Root-Filesystem Repair via chroot Lab](./labs/lab-01/README.md) | Prove The Fix And Unmount | Fixed a mistyped UUID in a stand-in system's `/etc/fstab` through a chroot |
| [chroot Repair: Wrong fstab Filesystem Type Lab](./labs/lab-02/README.md) | Prove The Fix And Unmount | Found and fixed a wrong filesystem type in an fstab line whose device was correct |

If you skipped one, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. A server stops at an emergency shell after someone edited <code>/etc/fstab</code>. Which component stopped the boot, and why?</summary>

systemd. It turned the bad line into a mount unit that could never succeed, waited for the device, and then switched to `emergency.target` because `local-fs.target` failed.
</details>

<details>
<summary>2. The GRUB menu still works. Which one-boot parameter skips the bad fstab line?</summary>

`systemd.unit=emergency.target`. It mounts only the root filesystem, read-only. Remount it read-write with `mount -o remount,rw /` and fix the line.
</details>

<details>
<summary>3. Inside a chroot, <code>blkid</code> prints nothing, even though the disk has partitions. What did you forget?</summary>

To bind-mount `/dev`, `/proc` and `/sys` into the target before running `chroot`. Without `/dev` there are no device files for `blkid` to read.
</details>

<details>
<summary>4. Why do you check <code>/etc/hostname</code> right after <code>chroot</code>?</summary>

To prove you are inside the target. If it shows the repair host's name, any edit would change the repair host's own files.
</details>

<details>
<summary>5. The UUID in an fstab line matches <code>blkid</code>, but <code>mount -a</code> says <code>wrong fs type, bad superblock</code>. Where do you look?</summary>

At field 3, the filesystem type. Compare it with `TYPE=` in the `blkid` output and correct it.
</details>

<details>
<summary>6. What does <code>mount -a; echo $?</code> printing <code>0</code> tell you?</summary>

That every line in that `/etc/fstab` can be mounted as written, which is the same check systemd does at boot. It is your proof before a reboot.
</details>

<details>
<summary>7. <code>sudo umount /mnt/repair</code> answers <code>target is busy</code>. What is wrong?</summary>

Other mounts (the bind mounts or `/mnt/repair/data`) are still mounted inside it. Unmount them first, in reverse order, or use `sudo umount -R /mnt/repair`.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If a mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-081
astrona destroy ats-002-lab-085
```

Then run `astrona list` again to check that everything is gone.
