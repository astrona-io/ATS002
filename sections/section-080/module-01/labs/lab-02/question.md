# Question

Solve this question on: `terminal`

An administrator added a `/data` mount to `/etc/fstab` on the `data-002` host. On the next boot, systemd hangs on that mount and drops to an emergency shell.

So that your own machine stays reachable, the `data-002` disk is a second, disposable disk already attached to this machine (serial `lab085-data002`). It has two partitions:

- a small root partition for `data-002`, carrying its own `/etc/fstab`
- a data partition, the volume that the `/data` line is meant to mount

This time the device identifier in the `/data` line is **correct**. The fault is somewhere else in the line.

Repair the stand-in system with a chroot:

1. Identify the two partitions on the stand-in disk. Do not assume a device letter such as `/dev/vdb`.
2. Mount the stand-in root partition at `/mnt/repair`.
3. Bind-mount this machine's `/usr`, `/bin`, `/sbin` and `/lib` (and `/lib64` if it exists) into `/mnt/repair`, then bind-mount `/dev`, `/proc` and `/sys`.
4. `chroot` into `/mnt/repair`.
5. Run `mount -a` and read the error carefully. Then compare every field of the `/data` line with what `blkid` reports for the data partition, and correct the field that is wrong. Leave the device identifier as it is.
6. Run `mount -a` again and confirm it exits with `0` and that `/data` is mounted.
7. Leave the chroot and unmount everything.

The grader mounts the stand-in root partition read-only, from outside any chroot, and checks the `/data` line in its `/etc/fstab`:

- the filesystem type (field 3) matches the data partition's real type as reported by `blkid`
- the device (field 1) still identifies the data partition, either as `UUID=<its real UUID>` or as a `/dev/disk/by-...` path
