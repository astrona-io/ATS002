# Question

Solve this question on: `terminal`

An administrator edited `/etc/fstab` on the `data-001` host to add a mount for a new data volume on `/data`, and mistyped the device's UUID. On the next boot, systemd would wait on the bad mount and drop to an emergency shell.

So that your own machine stays reachable, the `data-001` disk is a second, disposable disk already attached to this machine (serial `lab081-data001`). It has two partitions:

- a small root partition for `data-001`, carrying its own `/etc/fstab` with the typo
- a data partition, the volume that the `/data` line is meant to mount

Do not assume a device letter such as `/dev/vdb`; find the disk yourself.

Repair the stand-in system the way you would repair a real one, with a chroot:

1. Identify the two partitions on the stand-in disk.
2. Mount the stand-in root partition at `/mnt/repair`.
3. Bind-mount this machine's `/usr`, `/bin`, `/sbin` and `/lib` (and `/lib64` if it exists) into `/mnt/repair`, so the chroot has working tools. The stand-in disk carries only configuration, not its own programs.
4. Bind-mount `/dev`, `/proc` and `/sys` into `/mnt/repair`.
5. `chroot` into `/mnt/repair`.
6. Find the mistyped UUID in `/etc/fstab`, compare it with the real UUID of the data partition, and correct it. Keep the rest of the line as it is: mount point `/data`, type `ext4`.
7. Still inside the chroot, run `mount -a` and confirm it exits with `0` and that `/data` is mounted.
8. Leave the chroot and unmount everything.

The grader mounts the stand-in root partition read-only, from outside any chroot, and checks that its `/etc/fstab` has a line that mounts `UUID=<real UUID of the data partition>` on `/data` as `ext4`.
