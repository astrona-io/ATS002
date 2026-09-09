# section-080 / module-02: Password Reset & Single-User Recovery

QEMU VM for the LFCS course — chroot-based root password recovery on a disposable stand-in disk representing a locked-out "data-001" host.

## How This Lab Stays Safely Gradable

The real-world technique for this scenario (`rd.break` or `init=/bin/bash`, interrupting a real GRUB menu) is an interactive, console-only maneuver this platform's SSH-driven grading harness cannot script. So instead of touching your primary VM's own boot process, bootstrap attaches a second, disposable disk (`extraDisks`, serial `lab082-data001`) carrying its own `/etc/shadow`, with root's password field seeded to `!` (locked). Your job is to mount that disk, chroot in, and reset root's password hash for real — the same chroot-based credential-repair mechanic taught in Module 1, applied here to a locked account instead of a bad mount.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-02/labs/lab-01
```
