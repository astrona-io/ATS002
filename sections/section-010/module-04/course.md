# Chapter 4: udev — Giving a Device a Name It Can Keep

`/dev/sdb` is not a promise. It's a race result.

Every block device letter the kernel hands out — `sda`, `sdb`, `sdc`, or in a virtualized environment `vda`, `vdb` — is assigned purely in the order the kernel happened to discover that device during boot or hotplug. Nothing about that letter is tied to the physical drive itself. Plug in a second USB drive for an unrelated, temporary task, and if it happens to get discovered first, it can shove your intended drive down a letter — silently, with no warning, no error, nothing on screen to tell you it happened.

Now imagine a nightly backup script with `/dev/sdb1` hardcoded into it. The night an extra device grabs that letter first, the backup script keeps running exactly as before — except now it's confidently, silently backing up (or worse, overwriting) the wrong device entirely. This chapter is about the tool that solves this problem for good: `udev`.

> `/dev/sdb` names a *slot* in enumeration order, not a *device*. If a script needs to always mean "that one specific physical drive," it needs a name keyed off something the device actually carries with it — like a serial number — not a name keyed off when the kernel happened to notice it.

---

## Part I: Finding an Identity the Device Actually Owns

`udev` is the userspace layer that turns raw kernel device-discovery events into the device nodes and symlinks you see under `/dev`. It is fully rule-driven, which means you can teach it to recognize one specific physical device and hand it a name of your choosing, no matter which `/dev/sdX` slot it happens to land in on any given day.

The first step is finding something about the device that doesn't change — an attribute the hardware itself carries, rather than something the kernel merely assigned it this time around.

```bash
lsblk
```

Confirm which raw device node your target currently occupies. Then ask udev what it already knows about that device:

```bash
udevadm info --query=all --name=/dev/sdc
```

This dumps every property udev has already recorded for that device node — often including `ID_SERIAL`, `ID_VENDOR`, and `ID_MODEL`, already derived by udev's own built-in rules. Sometimes that's all you need. But sometimes the attribute you actually want — a hardware serial number in particular — doesn't live at the device node's own level; it lives one or two steps up, on a parent controller or bus node. For that, reach for a different mode entirely:

```bash
udevadm info --attribute-walk --name=/dev/sdc
```

`man udevadm` distinguishes these two modes clearly: `--query=all` gives you a flat dump of the one device node, while `--attribute-walk` climbs the device's entire ancestry in the kernel's `sysfs` tree — the device itself, then its parent bus, then its parent controller — printing every `ATTRS{}` value visible at each level. This is the mode to reach for specifically when hunting for a serial number, because a flat query at the leaf level frequently doesn't expose it at all.

The two values that matter most for what comes next are `ATTRS{serial}` — a stable identifier baked into the hardware itself — and `SUBSYSTEM=="block"`, which scopes any rule you write to block devices specifically, rather than every other subsystem node this same ancestry chain might also happen to match.

---

## Part II: Writing the Rule

Custom rules belong in exactly one place: `/etc/udev/rules.d/`. Never in `/lib/udev/rules.d/` or `/usr/lib/udev/rules.d/` — those directories are owned by installed packages, and the next package update can silently overwrite or revert anything you put there. `/etc/udev/rules.d/` is the designated, package-manager-untouched home for local administrator rules, and it takes precedence in udev's processing order regardless.

```bash
# /etc/udev/rules.d/99-backup-drive.rules
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", ENV{ID_FS_TYPE}=="ext4", SYMLINK+="backup-drive1"
```

Read that syntax carefully — `man 7 udev` draws a sharp line between **match keys** (double equals, `==`, a condition that must hold true for this rule to apply) and **assignment keys** (single equals or `+=`, which set a value once the match succeeds). `SYMLINK+=` deliberately uses `+=` rather than `=`, because it's *additive* — it appends one more name to the list of symlinks udev will create for this device, rather than overwriting whatever names the distro's built-in rules already assigned it. The kernel-assigned `/dev/sdc` doesn't disappear; `/dev/backup-drive` simply becomes an additional, parallel way to reach the same device node.

The first line matches the whole-disk device and creates `/dev/backup-drive`. The second line narrows further — matching only the partition whose filesystem type is `ext4` (via `ENV{ID_FS_TYPE}`, a property populated earlier in udev's own processing chain by its built-in `blkid` rules) — and creates `/dev/backup-drive1` for that specific partition, which is the node the backup script actually needs to mount.

A numeric filename prefix like `99-` places this rule late in udev's lexical processing order, the conventional way to make sure a custom rule runs after — and layers cleanly on top of — whatever the distro's built-in rules have already established for the device.

---

## Part III: Applying the Rule Without a Reboot

A new rule file sitting on disk does nothing until udev is told to notice it — and even then, "noticing" a new rule and "applying" it to hardware that's already connected are two separate steps:

```bash
sudo udevadm control --reload-rules
```

This tells the already-running `udevd` daemon to re-read every rule file from disk, right now. But it does **not**, by itself, re-evaluate any currently-attached device against that freshly-loaded rule. That second half needs its own explicit command:

```bash
sudo udevadm trigger --subsystem-match=block
```

`trigger` synthesizes fresh `add`/`change` events for devices that are already present, forcing udev to re-run its complete rule chain — including your brand-new rule — against them. Scoping it with `--subsystem-match=block` avoids unnecessarily re-triggering evaluation for every other already-settled device on the system.

Skipping the second command is a genuinely common trap: `--reload-rules` runs cleanly, produces no error, and looks for all the world like it worked — while quietly doing nothing at all to the device you actually care about.

---

## Part IV: Verifying and Watching Live

```bash
ls -l /dev/backup-drive /dev/backup-drive1
```

```text
lrwxrwxrwx 1 root root ... /dev/backup-drive -> sdc
lrwxrwxrwx 1 root root ... /dev/backup-drive1 -> sdc1
```

Both should resolve as symlinks pointing at whatever the current kernel-assigned letter happens to be. That's the entire point: the *target* of the symlink may shift on the next reconnect, but the symlink's own name — `/dev/backup-drive` — never does.

For a live view of udev doing its work, a second terminal running:

```bash
sudo udevadm monitor --udev --subsystem-match=block
```

streams every udev event as it happens in real time — the fastest way to actually watch an `add` event fire and confirm your rule fired correctly against it, rather than assuming from a static `ls` afterward.

---

## Part V: Finishing the Job

The udev rule only matters because of what it lets you do next: stop depending on kernel enumeration order anywhere in your tooling.

```bash
# before (fragile):
# mount /dev/sdb1 /mnt/backup

# after (stable):
mount /dev/backup-drive1 /mnt/backup
```

That one-line change is the actual fix. The rule is the mechanism; updating every script and config that used to hardcode a raw device letter is the reason the mechanism exists at all.

It's also worth knowing this problem is sometimes already solved for you without writing a single custom rule: `/dev/disk/by-id/`, `/dev/disk/by-uuid/`, and `/dev/disk/by-path/` exist out of the box on any modern distro, built from exactly this same kind of stable-attribute matching. Check those first — a hand-written `SYMLINK+=` rule earns its keep specifically when you need a particular, human-chosen name rather than one of the built-in ones.

---

## Self-Check and Verification

1. **Root cause**: What actually determines whether a drive becomes `/dev/sdb` versus `/dev/sdc` on any given boot? *(Answer: purely the order the kernel discovers it — nothing about the letter is tied to the physical device.)*
2. **Finding the serial**: Which `udevadm info` mode is best suited to hunting for an attribute that lives on a parent bus node rather than the device leaf itself? *(Answer: `--attribute-walk`.)*
3. **The forgotten second step**: After editing a rule file and running `udevadm control --reload-rules`, what command is still needed before an already-connected device picks up the change? *(Answer: `udevadm trigger`.)*
4. **Match vs. assign**: In `SUBSYSTEM=="block"`, is `==` a match condition or an assignment? *(Answer: a match condition — a single `=` would silently change the rule's meaning to an assignment instead.)*

You now understand how udev turns unstable kernel-assigned names into names you can actually trust in a script. The lab ahead hands you a disk and asks you to give it exactly that kind of name.
