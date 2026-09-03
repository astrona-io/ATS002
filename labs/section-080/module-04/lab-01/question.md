# Question

Solve this question on: `terminal`

**Scenario.** This VM's bootloader is stale. On the next reboot, GRUB would come up needing a configuration file that is no longer there — the on-disk equivalent of a machine dropping to a bare `grub>` rescue prompt with no menu at all. Your **current** session is unaffected: this VM's boot already completed before anything below was touched, GRUB's own installed boot-sector/EFI code was never corrupted, and SSH stays fully reachable throughout. Fix this before the next reboot happens, not after.

Your job:

1.  Confirm the symptom: `ls -l /boot/grub/grub.cfg` should show it missing.
2.  Determine this VM's firmware/boot mode before assuming a specific `grub-install` invocation: `[ -d /sys/firmware/efi ] && echo UEFI || echo "BIOS/legacy"`.
3.  Identify the primary disk backing your root filesystem with `lsblk` and `findmnt -no SOURCE /` (do not assume a specific `/dev/vdX` letter — confirm your own).
4.  Reinstall GRUB's own boot-sector or EFI code with `grub-install` — targeting the whole disk on BIOS/legacy (e.g. `sudo grub-install /dev/vda`), or the EFI system partition on UEFI (`sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi`).
5.  Regenerate a fresh `/boot/grub/grub.cfg` with `sudo update-grub`.
6.  Confirm the repair is durable, without needing an actual reboot to find out: `sudo grub-install --recheck` against the same disk/target you used in step 4 should report success, and `/boot/grub/grub.cfg` should exist, be non-empty, and contain real `menuentry` lines (`grep -c menuentry /boot/grub/grub.cfg`).

The fix is graded by confirming `/boot/grub/grub.cfg` exists, is non-empty, contains menu entries, and was genuinely regenerated during this session (not left over from the base VM image) — and separately, that GRUB's installed boot-sector/EFI image was also genuinely rewritten during this session.
