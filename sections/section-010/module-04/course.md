# udev: Giving a Device a Name It Can Keep

Astronaut, `/dev/sdb` is not a promise. It is a bay number handed out in arrival order: the kernel gives letters to disks in the order it discovers them on this boot, and the letter says nothing about the physical drive. Plug in an unrelated USB stick that the kernel finds first, and your disk moves one letter with no warning. A backup script with `/dev/sdb1` written into it then writes to the wrong disk.

udev is the fix. It is the dock master who names each arriving cargo bay: it turns the kernel's device events into entries under `/dev` by running rules. You can write a rule card that recognises one physical disk by something it really carries, its serial number, and gives it a name you choose.

## Learning objectives

After this module you can:

- **Explain** what really decides whether a drive is `/dev/sdb` or `/dev/sdc` on a given boot.
- **Find** a stable hardware attribute (a serial) with `udevadm info --attribute-walk`, including when it lives on a parent node.
- **Distinguish** match keys (`==`) from assignment keys (`=`, `+=`, `:=`), and `ATTR{}` from `ATTRS{}`.
- **Write** a rule in `/etc/udev/rules.d/` that matches one device by serial and adds a `SYMLINK+=` name without dropping the built-in links.
- **Apply** a new rule to a device that is already connected, with `udevadm control --reload-rules` followed by `udevadm trigger`.
- **Dry-run** a rule with `udevadm test` and watch events live with `udevadm monitor`.
- **Replace** hard-coded `/dev/sdX` names in scripts and `/etc/fstab`, and know when `/dev/disk/by-*` already solves the problem.

## Before you start

Check what this module expects you to know, and what is waiting in your playground.

### What you should already know

- **A Linux shell and `sudo`.** You can type commands and borrow the captain's authority for the ones that change the system.
- **Reading `ls -l` output for a symbolic link.** A line such as `backup-drive -> vdc` means the name `backup-drive` points at `vdc`.
- **Automatic loads.** When hardware appears, the kernel sends an event, and udev reacts to it, for example by loading the right driver. This module uses the same events to name disks.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with a **spare 1 GiB disk, `/dev/vdc`, with the serial `BACKUPWD42`**. It is attached so you have a real device to write a rule for. `vda` is the operating system disk and `vdb` is a small cloud-init disk. The spare disk's letter is not guaranteed, so if `lsblk` shows it under another name, use that name wherever the pages say `/dev/vdc`. The `udev` and `util-linux` tools are installed, and `/etc/udev/rules.d/` holds no custom rules yet.

Start the playground, then open a terminal on it with `astrona ssh astro-udev-stable-naming`. Every command block also says which shell and which privileges it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Device Events And A Stable Identity](./course-01-device-events-and-identity.md): how a `/dev` node comes from a kernel uevent, why the letter means nothing, the sysfs parent chain, and `udevadm info --query=all` versus `--attribute-walk`.
2. [Writing The udev Rule](./course-02-writing-the-rule.md): where rule files go and why `/etc/udev/rules.d/` with a `99-` prefix wins, the `==`, `!=`, `=`, `+=` and `:=` operators, and a worked two-line `SYMLINK+=` rule on `ATTRS{serial}`.
3. [Applying And Using The Rule](./course-03-applying-verifying-and-using.md): `udevadm control --reload-rules` and `udevadm trigger` (two steps; skipping the second is the trap), `udevadm test` and `monitor`, and moving scripts and `/etc/fstab` off raw device letters.
   - Mission: [Stable Device Naming with udev Lab](./labs/lab-01/README.md)
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

Disk letters change more often than people expect: a new disk, a USB stick, a different boot order. Every script and `/etc/fstab` line that names a raw letter is a quiet risk of writing to the wrong disk. A stable name, proved with a check command, removes that risk, and the exam expects you to create one under time pressure.
