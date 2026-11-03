# Overview: udev Stable Naming Playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh`, and waits for you. There is no task, no `astrona submit`, and no pass or fail.

## What is in the box

- One Ubuntu 24.04 virtual machine (`qemu`). Open a terminal on it with `astrona ssh astro-udev-stable-naming`.
- `udev` with `udevadm`, and `util-linux` with `lsblk`.
- `lsblk` shows three disks:
  - `vda`: the 15 GiB operating system disk;
  - `vdb`: a small cloud-init configuration disk of about 366 KiB;
  - `vdc`: a **1 GiB spare disk with the serial `BACKUPWD42`**, attached so you have a real device to write a rule for. Its letter is not guaranteed: if `lsblk` shows it under another name, use that name in place of `vdc`.
- No custom udev rules are installed. `/etc/udev/rules.d/` holds only what Ubuntu ships.

## Things to try

- `udevadm info --query=all --name=/dev/vdc`: the flat property list. Look for `ID_SERIAL` and `ID_SERIAL_SHORT`.
- `udevadm info --attribute-walk --name=/dev/vdc | grep -iE 'serial|SUBSYSTEM'`: the walk up the parent chain.
- Save a rule as `/etc/udev/rules.d/99-backup.rules` that matches the serial `BACKUPWD42` and adds `SYMLINK+="backup-drive"`.
- Run `sudo udevadm control --reload-rules`, then `sudo udevadm trigger --subsystem-match=block`, then `ls -l /dev/backup-drive`.
- `udevadm test "$(udevadm info -q path -n /dev/vdc)" 2>&1 | grep -i symlink`: dry-run the rule.

## When you are done

```sh
astrona destroy udev-stable-naming
```
