# Question

Solve this question on: `terminal`

This machine's bootloader is in trouble. `/boot/grub/grub.cfg` is missing, so on the next reboot GRUB would have no menu to show. That is the on-disk version of a machine stopping at a bare `grub>` prompt.

Your current session is not affected. The machine finished booting before the file was removed, GRUB's installed boot code was not damaged, and SSH keeps working. Fix the problem now, before the next reboot.

1. Confirm the symptom: `/boot/grub/grub.cfg` is missing.
2. Find out whether this machine started with BIOS or UEFI firmware before you choose a `grub-install` command.
3. Identify the disk that holds your root filesystem. Do not assume a device letter; check it yourself.
4. Reinstall GRUB's boot code with `grub-install`: on BIOS, target the whole disk; on UEFI, target the EFI system partition with `--target=x86_64-efi --efi-directory=/boot/efi`.
5. Write a fresh `/boot/grub/grub.cfg` with `update-grub`.
6. Without rebooting, check the repair: `grub-install --recheck` against the same disk or target must succeed, and `/boot/grub/grub.cfg` must contain `menuentry` lines.

Do not reboot before the repair is finished: the machine would not come back.

The grader checks that:

- `/boot/grub/grub.cfg` exists, is not empty, has at least one line starting with `menuentry`, and was written after the lab was set up
- GRUB's installed core image (`core.img` or `core.efi` under `/boot/grub`) was rewritten after the lab was set up, which shows you really ran `grub-install`
- `grub-install --recheck` on the disk behind `/` (or in its UEFI form) finishes without an error
