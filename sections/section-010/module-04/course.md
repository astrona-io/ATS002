# Chapter 4: udev — Giving a Device a Name It Can Keep

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS002/tree/main/sections/section-010/module-04/playground)
>
> ```sh
> astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-04/playground
> astrona destroy udev-stable-naming
> ```

`/dev/sdb` is not a promise, it is a race result: the letter is assigned in the order the kernel discovered devices this boot, tied to nothing about the physical drive. Plug in an unrelated USB stick that gets probed first and your intended disk shifts a letter with no warning — and a backup script with `/dev/sdb1` hardcoded quietly starts writing the wrong device. `udev` is the fix: it turns kernel device-discovery events into `/dev` nodes by running rules, and you can write a rule that recognises one specific physical device by an attribute it actually carries — a serial number — and hands it a name of your choosing.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Device events, sysfs, and finding a stable identity](./course-01-device-events-and-identity.md)** — how a `/dev` node is created from a kernel uevent, why the kernel letter means nothing, the sysfs parent chain, and `udevadm info --query=all` vs `--attribute-walk` for finding a serial that lives on a parent node.
2. **[Part 2 — Writing the rule: match keys vs. assignment keys](./course-02-writing-the-rule.md)** — where rule files go and why `/etc/udev/rules.d/` with a `99-` prefix wins, the `==` / `!=` / `=` / `+=` / `:=` operator vocabulary, and a worked two-line `SYMLINK+=` rule keyed on `ATTRS{serial}`.
3. **[Part 3 — Applying, verifying, and using the rule](./course-03-applying-verifying-and-using.md)** — `udevadm control --reload-rules` vs `udevadm trigger` (two steps, skipping the second is the trap), `udevadm test` and `monitor`, and repointing scripts and `/etc/fstab` off raw device letters.

## Learning objectives

After this module you can:

- **Explain** what actually determines whether a drive is `/dev/sdb` or `/dev/sdc` on a given boot.
- **Find** a stable hardware attribute (serial) with `udevadm info --attribute-walk`, including when it lives on a parent bus node.
- **Distinguish** match keys (`==`) from assignment keys (`=`, `+=`, `:=`), and `ATTR{}` from `ATTRS{}`.
- **Write** a rule in `/etc/udev/rules.d/` that matches one device by serial and adds a `SYMLINK+=` name without dropping the built-in links.
- **Apply** a new rule to an already-connected device with `udevadm control --reload-rules` followed by `udevadm trigger`.
- **Dry-run** a rule with `udevadm test` and watch events live with `udevadm monitor`.
- **Replace** hardcoded `/dev/sdX` references in scripts and `fstab`, and know when `/dev/disk/by-*` already solves the problem.

## Before you start

Assumed: Chapter 3's automatic-versus-explicit load idea (udev is what fires those automatic loads), a Linux shell, `sudo`, and reading `ls -l` symlink output.

The playground (callout above) is a throwaway Ubuntu 24.04 VM with a **spare 1 GiB disk `/dev/vdc`, serial `BACKUPWD42`**, attached so you have a real device to write a rule for (`vda` is the OS disk, `vdb` the cloud-init disk). Get a shell with `astrona ssh astro-udev-stable-naming`. The **Try it** checkpoints in Parts 1–3 run there; every command block also states the shell and privilege it assumes.

## Where this fits

This module is the point of the section's "stable names" thread: Chapter 1 read kernel state precisely, and this chapter makes *device* names precise too, so the tooling built on top does not depend on enumeration order. The section capstone attaches a new disk and asks you to give it exactly this kind of name before the rest of the incident work can rely on it.
