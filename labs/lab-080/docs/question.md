# Question

Solve this question on: `terminal`

**Scenario.** You've just been paged. Two things are wrong on this host at once:

1.  Its secondary disk's GPT partition table is gone. A backup taken before this incident already exists on disk at `/root/vdc-ptable-backup.bin` — restore from it rather than reconstructing partitions from memory.
2.  Its own bootloader is stale: `/boot/grub/grub.cfg` is missing, so the next reboot would come up needing a configuration that isn't there. Your **current** SSH session is unaffected — this VM's boot already completed before anything went wrong, and GRUB's own installed boot-sector/EFI code was never corrupted — but fix this before the next reboot happens, not after.

Your job:

**Part 1 — Secondary disk (partition table restore):**

1.  Identify the secondary disk with `lsblk -f` (it is **not** the disk mounted as `/`, and it currently shows no partitions at all — do not assume a specific `/dev/vdX` letter).
2.  Confirm the existing backup is sane: `sudo sgdisk --print /root/vdc-ptable-backup.bin`.
3.  Restore the partition table from it: `sudo sgdisk --load-backup=/root/vdc-ptable-backup.bin <disk>`.
4.  Confirm partitions reappear with `lsblk -f`, then — as a **separate** check — confirm the filesystems inside are actually intact: run `fsck -n` on each partition, and mount each one to confirm its original `marker.txt` file is still there with its original content.

**Part 2 — Primary disk (GRUB reinstall):**

5.  Confirm the symptom: `ls -l /boot/grub/grub.cfg` should show it missing.
6.  Determine this VM's firmware/boot mode: `[ -d /sys/firmware/efi ] && echo UEFI || echo "BIOS/legacy"`.
7.  Identify the primary disk backing your root filesystem with `lsblk` and `findmnt -no SOURCE /` (do not assume a specific `/dev/vdX` letter).
8.  Reinstall GRUB's own boot-sector or EFI code with `grub-install` — targeting the whole disk on BIOS/legacy, or the EFI system partition on UEFI.
9.  Regenerate a fresh `/boot/grub/grub.cfg` with `sudo update-grub`.
10. Confirm the repair is durable without rebooting: `sudo grub-install --recheck` against the same disk/target should report success, and `/boot/grub/grub.cfg` should contain real `menuentry` lines.

The fix is graded on four checks: the secondary disk's partition table is back with both original partitions present; both partitions' filesystems pass `fsck -n` and their original marker files are intact; `/boot/grub/grub.cfg` exists, is non-empty, contains menu entries, and was genuinely regenerated during this session; and GRUB's installed boot-sector/EFI image was also genuinely rewritten during this session.
