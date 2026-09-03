# Question

Solve this question on: `terminal`

**Scenario.** An admin edited `/etc/fstab` on the `data-001` host to add a new data-volume mount and made a typo in the device identifier. On the next boot, systemd would hang waiting on the bad mount and drop to an emergency shell instead of completing startup. So this lab doesn't strand the VM you're SSHed into, `data-001`'s disk is represented by a second, disposable virtio disk already attached to this VM — its own small root partition (carrying its own `/etc/fstab`, with the typo already seeded) and its own small data partition (the volume that fstab entry is supposed to mount).

Your job:

1.  Identify the two partitions on the stand-in disk with `lsblk -f` (do not assume a specific `/dev/vdX` letter — it can vary).
2.  Mount the stand-in disk's root partition at `/mnt/repair`.
3.  Bind-mount this VM's own `/usr`, `/bin`, `/sbin`, `/lib` (and `/lib64` if present) into `/mnt/repair` **read-only**, so the chroot has working tools — the stand-in disk only carries the broken configuration, not a full duplicate userland.
4.  Bind-mount `/dev`, `/proc`, and `/sys` into `/mnt/repair` as well — the step every real chroot repair needs and most guides skip.
5.  `chroot` into `/mnt/repair`.
6.  Inside the chroot, find the mistyped UUID in `/etc/fstab` (cross-check it against `blkid`'s real output) and correct it so it matches the data partition's actual UUID.
7.  Still inside the chroot, run `mount -a` and confirm it exits `0` with the `/data` entry now actually mounted — proving the fix works before you'd ever trust a real reboot to it.
8.  Exit the chroot and unmount everything cleanly, in reverse order.

The fix is graded by re-mounting the stand-in disk's root partition (read-only, from outside any chroot) and confirming `/etc/fstab` now references the data partition's real UUID.
