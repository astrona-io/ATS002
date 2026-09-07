# Overview — udev stable-naming playground

A **playground**, not a lab: boots, runs `bootstrap/prepare.sh`, waits. No task, no `astrona submit`, no pass/fail.

## What's in the box

- One Ubuntu 24.04 qemu VM, reached with `astrona ssh astro-udev-stable-naming`.
- `udev` + `udevadm`, and `util-linux` (`lsblk`).
- `lsblk` shows:
  - `vda` — the ~15 GiB OS disk
  - `vdb` — the ~366 KiB cloud-init config disk
  - `vdc` — a **1 GiB spare disk with serial `BACKUPWD42`**, attached for this module so you have a real device to write a rule for
- No custom udev rules are installed — `/etc/udev/rules.d/` holds only what the distro ships.

## Things to try

- `udevadm info --query=all --name=/dev/vdc` — the flat property dump (look for `ID_SERIAL`, `ID_SERIAL_SHORT`).
- `udevadm info --attribute-walk --name=/dev/vdc | grep -iE 'serial|SUBSYSTEM'` — the ancestry walk.
- Write `/etc/udev/rules.d/99-backup.rules` matching `ATTRS{serial}=="BACKUPWD42"` with `SYMLINK+="backup-drive"`.
- `sudo udevadm control --reload-rules` then `sudo udevadm trigger --subsystem-match=block`, then `ls -l /dev/backup-drive`.
- `udevadm test "$(udevadm info -q path -n /dev/vdc)" 2>&1 | grep -i symlink` — dry-run the rule.

## When you're done

```sh
astrona destroy udev-stable-naming
```
