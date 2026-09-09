# section-080 / module-01: Root-Filesystem Repair via chroot

QEMU VM for the LFCS course — chroot-based recovery of a broken `/etc/fstab` entry on a disposable stand-in disk representing a "data-001" host that failed to boot.

## How This Lab Stays Safely Gradable

Your primary VM's own root filesystem and boot process are never touched. Bootstrap attaches a second, disposable disk (`extraDisks`, serial `lab081-data001`) and builds a small standalone filesystem tree on it — its own `/etc/fstab`, deliberately seeded with a mistyped UUID. Your job is to mount that disk, bind-mount your primary VM's own tools into it, `chroot` in, and fix the typo — the exact same mechanic a real chroot repair uses, aimed at a safe stand-in instead of the machine you're SSHed into.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-01
```
