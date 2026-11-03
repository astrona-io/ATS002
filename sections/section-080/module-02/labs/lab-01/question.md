# Question

Solve this question on: `terminal`

The root password on the `data-001` host is lost, and no other account has `sudo` rights. On a real server you would interrupt GRUB for one boot with `rd.break` or `init=/bin/bash`. The grader works over SSH and cannot do that, so this task practises the chroot half of the same repair.

The `data-001` disk is a second, disposable disk already attached to this machine (serial `lab082-data001`). The whole disk holds one root filesystem, with no partitions. In its `/etc/shadow`, root's account is locked: the password field is `!`. Do not assume a device letter such as `/dev/vdb`; find the disk yourself.

Reset root's password on the stand-in system:

1. Identify the stand-in disk.
2. Mount it at `/mnt/repair`.
3. Bind-mount this machine's `/usr`, `/bin`, `/sbin` and `/lib` (and `/lib64` if it exists) into `/mnt/repair`, so the chroot has working tools.
4. Bind-mount `/dev`, `/proc` and `/sys` into `/mnt/repair`.
5. `chroot` into `/mnt/repair`.
6. Give root a real password hash in `/etc/shadow`, in place of the `!` in the second field. The stand-in disk has no full PAM setup, so `passwd root` may fail. In that case, make a hash with `openssl passwd -6 '<your password>'` and put it into the second field of root's line. Leave the other fields as they are.
7. Leave the chroot and unmount everything.

The grader mounts the stand-in disk read-only, from outside any chroot, and checks root's line in its `/etc/shadow`: the second field must not be empty and must not be a lock placeholder (`!`, `!!` or `*`). The password itself is not checked.
