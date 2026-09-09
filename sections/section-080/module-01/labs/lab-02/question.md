# Question

Solve this question on: `terminal`

**Scenario.** An admin added a `/data` mount to `/etc/fstab` on the
`data-002` host. On the next boot, systemd hangs on that mount and drops to
an emergency shell. As in lab-01, `data-002`'s disk is a second disposable
virtio disk attached to this VM (serial `lab085-data002`), with its own
small root partition (carrying its own `/etc/fstab`) and its own data
partition.

This time the fstab entry's **device identifier is correct** — the fault is
elsewhere in the line.

1. Identify the two partitions on the stand-in disk with `lsblk -f` (do not
   assume a `/dev/vdX` letter).
2. Mount the stand-in root partition at `/mnt/repair`.
3. Bind-mount this VM's own `/usr`, `/bin`, `/sbin`, `/lib` (+ `/lib64` if
   present) into `/mnt/repair` **read-only**, then bind-mount `/dev`,
   `/proc`, `/sys`.
4. `chroot` into `/mnt/repair`.
5. Inside the chroot, run `mount -a` and read the failure carefully. Then
   cross-check the `/data` entry against `blkid` — every field, not just
   the device. Correct the wrong field so the entry matches reality.
6. Run `mount -a` again and confirm it exits `0` with `/data` mounted.
7. Exit the chroot and unmount everything cleanly, in reverse order.

Graded by re-mounting the stand-in root partition read-only and confirming
`/etc/fstab`'s `/data` entry now matches the data partition's real
filesystem type.
