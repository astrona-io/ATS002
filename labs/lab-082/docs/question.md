# Question

Solve this question on: `terminal`

**Scenario.** The root password on the `data-001` host is lost, and there's no other account with `sudo` privileges to fall back on. In the real world, the fix is to interrupt GRUB for a single boot (`rd.break` or `init=/bin/bash`) and reset the password directly — a physical-console technique this platform's SSH-based grading cannot script. So this lab practices the chroot half of that same mechanic on a disposable stand-in: `data-001`'s disk is represented by a second virtio disk already attached to this VM, formatted with its own root filesystem, whose `/etc/shadow` currently has root's account locked (password field `!`).

Your job:

1.  Identify the stand-in disk with `lsblk -f` (do not assume a specific `/dev/vdX` letter).
2.  Mount it at `/mnt/repair`.
3.  Bind-mount this VM's own `/usr`, `/bin`, `/sbin`, `/lib` (and `/lib64` if present) into `/mnt/repair` **read-only**, so the chroot has working tools.
4.  Bind-mount `/dev`, `/proc`, and `/sys` into `/mnt/repair`.
5.  `chroot` into `/mnt/repair`.
6.  This stand-in disk is minimal and doesn't carry a full PAM/login stack, so the interactive `passwd root` command may complain about missing configuration. Instead, generate a real password hash directly with `openssl passwd -6 '<your-chosen-password>'`, and splice that hash into root's line in `/etc/shadow`, replacing the `!` in the second colon-delimited field.
7.  Exit the chroot and unmount everything cleanly.

The fix is graded by re-mounting the stand-in disk (read-only, from outside any chroot) and confirming root's `/etc/shadow` hash field is non-empty and no longer the locked `!` placeholder. The plaintext password itself is never checked — only that a real hash now exists.
