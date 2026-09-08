# Password Reset & Single-User Recovery

Losing the root password is a different problem from an unbootable system: the machine boots perfectly, every service starts, the login prompt appears on schedule — only proof of identity is missing, and there is no other privileged account to `sudo` from. Full rescue media works but is overkill. The fast technique interrupts the bootloader for a single boot, edits the kernel command line for that boot only, and lands you in a root shell before any login prompt — nothing saved, one borrowed boot cycle.

Two short parts; work them in order.

## How this module is organised

1. **[Part 1 — Two doors: `rd.break` and `init=/bin/bash`](./course-01-two-doors-rd-break-and-init.md)** — the one-boot GRUB edit, and where each parameter drops you (`rd.break` in the initramfs with the real root read-only at `/sysroot`; `init=/bin/bash` on the real root as PID 1), plus the SELinux `/.autorelabel` gotcha.
2. **[Part 2 — The chroot equivalent, and editing `/etc/shadow` directly](./course-02-chroot-equivalent-and-shadow-edit.md)** — why the chroot mechanic reaches the same end state, and generating a `$6$` hash with `openssl passwd -6` to splice into `/etc/shadow` when the target has no working `passwd`.

## Learning objectives

After this module you can:

- **Choose** a one-boot kernel-parameter edit over rescue media for a healthy but locked-out system.
- **Describe** where `rd.break` and `init=/bin/bash` each land you and the extra steps each needs.
- **Remount** the target root read-write and reset the password, exiting each path correctly.
- **Flag** an SELinux relabel with `/.autorelabel` when the target is enforcing.
- **Generate** a SHA-512-crypt hash and edit only the correct `/etc/shadow` field when `passwd` is unavailable.

## Before you start

Assumed: Module 1's chroot mechanic, a Linux shell, `sudo`, and the `/etc/shadow` field layout. **How the lab runs:** the SSH-only grading harness cannot type into a GRUB menu or recover an unbootable VM, so the lab reuses Module 1's disposable-disk stand-in — you aim the chroot-then-reset sequence at that disk. Know the `rd.break` / `init=/bin/bash` keystrokes for the exam; the lab drills everything else about the technique.

## Where this fits

This is the second of the section's chroot-repair modules — same mechanic as Module 1, aimed at a credential store instead of an fstab line. The direct `/etc/shadow` hash edit is the fallback the section capstone expects when an interactive `passwd` will not run.
