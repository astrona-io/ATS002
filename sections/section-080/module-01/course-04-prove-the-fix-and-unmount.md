# Prove The Fix And Unmount

Astronaut, a corrected line is only a guess until you have seen it work. This part shows how to prove the fix inside the chroot, before any reboot, and then how to leave the damaged ship and pack up your cables in the right order. "Prove it inside the chroot first" is the core habit of the whole technique.

The commands below run inside the chroot you entered with `sudo chroot /mnt/repair /bin/bash`, after fixing the `/data` line in `/etc/fstab`.

## Prove the fix before you reboot

Ask `mount` to do what systemd would do at boot:

```bash
mount -a
echo $?
```

`mount -a` mounts every line in this `/etc/fstab` that is not already mounted and not marked `noauto`. It is the same check systemd performs during boot, but you run it on demand and get a clear answer instead of a stuck boot. `echo $?` prints its exit code: `0` with no error output means every line, as written, can be mounted.

Then check that the corrected line really mounted:

```bash
df -h /data     # confirm the corrected entry actually mounted
```

If `df` shows the data partition on `/data`, the fix works. If `mount -a` prints an error, read it carefully. `can't find UUID` points at field 1. `wrong fs type, bad option, bad superblock` usually points at field 3. Fix and run `mount -a` again until the exit code is `0`.

Why not just reboot and see? Because a second failed boot after a rushed edit makes the outage worse. Now you are debugging the first problem and whatever the rushed fix broke.

## When the bootloader or initramfs was also touched

A pure fstab typo needs nothing else. If the failure also involved GRUB or the initramfs, the small starter system the kernel loads first, regenerate them from inside the chroot. They must point at the target's own kernel and configuration, not the repair host's:

```bash
update-grub && update-initramfs -u        # Debian/Ubuntu
grub2-mkconfig -o /boot/grub2/grub.cfg && dracut --force   # RHEL/openSUSE
```

Run only the line for the target's family. This needs a full target system with its own `/boot`, not a stand-in disk that only carries `/etc`.

## Leave the chroot and unmount in reverse order

Leave the chroot first, then unmount from the inside out:

```bash
exit                    # leave the chroot
sudo umount /mnt/repair/data     # anything mounted *inside* the chroot first
sudo umount /mnt/repair/dev /mnt/repair/proc /mnt/repair/sys
sudo umount /mnt/repair/lib64 2>/dev/null
sudo umount /mnt/repair/lib /mnt/repair/sbin /mnt/repair/bin /mnt/repair/usr
sudo umount /mnt/repair          # the target root last
```

Unmount in the reverse order of mounting. The kernel will not unmount a filesystem while something else is still mounted inside it, and it answers `target is busy`. `/mnt/repair/data` came last (from `mount -a`), so it goes first, and the target root goes last.

`sudo umount -R /mnt/repair` does the same job in one command: `-R` unmounts everything under `/mnt/repair` and then `/mnt/repair` itself. Use it once the single steps make sense to you.

On a real system, this is where you reboot and watch it come up without help. On the missions' stand-in disk, the corrected `/etc/fstab` on that disk is the proof.

## Common pitfalls

> [!WARNING]
> - **Editing `/etc/fstab` and rebooting without `mount -a`.** You risk a second failed boot and two problems to debug. Always prove it in the chroot.
> - **Running `update-grub` or `dracut` outside the chroot.** They then target the repair host's kernel, not the broken system's.
> - **Unmounting `/mnt/repair` before the mounts inside it.** You get `target is busy`. Go in reverse order, or use `umount -R`.
> - **Reading `echo $?` too late.** Any command in between replaces the exit code. Run `echo $?` straight after `mount -a`.

## Your mission: Root-Filesystem Repair via chroot Lab

You can now mount a broken root, build a working chroot, fix a bad fstab line against `blkid` and prove it with `mount -a`. The mission asks you to repair a stand-in system whose `/etc/fstab` has a mistyped UUID.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-01
astrona ssh ats-002-lab-081
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-01/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-081
```

## Your mission: chroot Repair: Wrong fstab Filesystem Type Lab

You can now check every field of an fstab line, not just the device. The mission asks you to repair a stand-in system whose `/data` line points at the right device but still will not mount.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-02
astrona ssh ats-002-lab-085
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-01/labs/lab-02
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-085
```
