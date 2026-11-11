# Question

Solve this question on: `terminal`

You have just been paged. Two things are wrong on this host at once:

- **The secondary disk's GPT partition table is gone.** A backup taken before the incident is on file at `/root/vdc-ptable-backup.bin`. Restore from it instead of rebuilding partitions from memory.
- **The bootloader is in trouble.** `/boot/grub/grub.cfg` is missing, so the next reboot would find no menu. Your current SSH session is not affected: the machine finished booting before the file went missing, and GRUB's installed boot code was not damaged. Fix it before the next reboot.

## Task 1: Restore the secondary disk

1. Identify the secondary disk (serial `lab080-vdc`). It is **not** the disk mounted as `/`, and it currently shows no partitions at all. Do not assume a device letter such as `/dev/vdb`.
2. Check that the existing backup is good with `sgdisk --print` on the backup file.
3. Restore the partition table from it with `sgdisk --load-backup`.
4. Confirm the partitions are back, then check the filesystems separately: run `fsck -n` on each partition, and mount each one to confirm its `marker.txt` is still there with its original content. Unmount them again when you are done.

## Task 2: Repair GRUB on the main disk

5. Confirm the symptom: `/boot/grub/grub.cfg` is missing.
6. Find out whether this machine started with BIOS or UEFI firmware.
7. Identify the disk that holds your root filesystem. Do not assume a device letter.
8. Reinstall GRUB's boot code with `grub-install`: on BIOS, target the whole disk; on UEFI, target the EFI system partition with `--target=x86_64-efi --efi-directory=/boot/efi`.
9. Write a fresh `/boot/grub/grub.cfg` with `update-grub`.
10. Without rebooting, check the repair: `grub-install --recheck` against the same disk or target must succeed, and `/boot/grub/grub.cfg` must contain `menuentry` lines.

Do not reboot before the GRUB repair is finished: the machine would not come back.

## What the grader checks

- The secondary disk has both of its original partitions again.
- Each partition passes `fsck -n` without errors, mounts, and still holds its original `marker.txt` with its original content.
- `/boot/grub/grub.cfg` exists, is not empty, has at least one line starting with `menuentry`, and was written after the lab was set up.
- GRUB's installed core image (`core.img` or `core.efi` under `/boot/grub`) was rewritten after the lab was set up, and `grub-install --recheck` on the disk behind `/` (or in its UEFI form) finishes without an error.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md), [module-04](../../../module-04/course.md), [module-05](../../../module-05/course.md), [module-06](../../../module-06/course.md), [module-07](../../../module-07/course.md), [module-08](../../../module-08/course.md), [module-09](../../../module-09/course.md).

The grader checks:

- Confirms the secondary disk currently has 2 partitions matching the original layout.
- Confirms both partitions on the secondary disk mount cleanly and their original marker files are readable.
- Confirms /boot/grub/grub.cfg on the primary disk exists, is non-empty, contains menuentry lines, and was regenerated after bootstrap ran.
- Confirms GRUB's boot-sector/EFI code on the primary disk was genuinely reinstalled and grub-install --recheck reports success.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
