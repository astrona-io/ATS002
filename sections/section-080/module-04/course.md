# GRUB Corruption Recovery

Module 1 covered a bad `fstab` entry — the bootloader works fine, it's a mount instruction handed to systemd afterward that's wrong. This module covers a more fundamental failure: GRUB itself is broken. Either the machine drops straight to a bare `grub>` rescue prompt with no menu at all — GRUB's own files or configuration are missing or corrupted so badly it can't even build a menu — or a menu of sorts appears, but the configuration file it needs (`/boot/grub/grub.cfg` on Debian/Ubuntu-family systems, `/boot/grub2/grub.cfg` on RHEL/openSUSE-family systems) is missing or unreadable, leaving GRUB with nothing to actually boot.

Regenerating a config file, which is all Module 1's fix needed, is not the whole fix here. GRUB's own installed code — the boot-sector or EFI program the firmware hands control to first — and its ability to find a config at all may both be broken, and that calls for genuinely reinstalling GRUB to the disk, not just rebuilding a config file on top of it.

---

## Two Different Repairs, Easy to Confuse

It's worth being precise about two tools that sound like they do the same thing but genuinely don't:

**`grub-install`** (or `grub2-install` on RHEL/openSUSE-family systems) writes GRUB's actual **boot-sector or EFI executable code** — the very first, tiny program the firmware runs before anything else exists. This is what re-establishes GRUB's presence on the disk at all.

**`update-grub`** (or `grub2-mkconfig -o ...` on RHEL/openSUSE-family systems) generates the **menu configuration file** — the list of boot entries and their kernel/initrd parameters — assuming GRUB's own installed code is already present and working.

Think of a stage play: `grub-install` builds the stage itself — the physical structure that has to exist before any performance can happen at all. `update-grub` writes and prints the night's program — which acts go on, in what order. A missing program with a perfectly good stage still leaves the audience with nothing to watch; a beautifully printed program handed out in front of a stage that was torn down overnight is equally useless. A fully broken GRUB installation typically needs both repaired; a narrower problem (just a missing config, boot code otherwise intact) needs only the second.

`update-grub` on Debian/Ubuntu is not a different, simpler tool — it's a thin wrapper script that calls the exact same underlying `grub-mkconfig` machinery RHEL/openSUSE-family systems invoke more directly, just with the correct output path for that distribution already baked in.

---

## How This Module Stays Safely Gradable

This section has been upfront from Module 1 onward about a hard constraint: the lab harness grades your VM entirely by SSHing into it and running a script. It has no way to script an interactive `grub>` rescue prompt, and no way to recover from a VM that has genuinely stopped booting — which is exactly the scenario the source material for this topic describes (a machine dropping to a bare rescue prompt with no menu at all).

So this lab re-stages the scenario rather than skipping it. Bootstrap deliberately removes this VM's own `/boot/grub/grub.cfg` — the exact failure mode described above — but never touches the kernel already running in memory, and never touches GRUB's own installed boot-sector/EFI code. The result: your VM's **current** boot succeeded (it already happened, before the damage), and SSH stays fully available the entire time — but the **next** reboot, if one happened right now, would find no usable configuration and likely fail. The framing is deliberately "fix this before that next reboot happens," not "you're already down and I need you to fix it blind."

To keep the full skill intact rather than just the config-rebuild half of it, the lab still asks you to run both halves of a real repair — `grub-install` and `update-grub` — exactly as you would for a fully broken installation, even though this lab's specific damage only strictly required the second. Practicing both together, every time, is also the right habit for the real exam and real incidents: a config rebuilt on top of genuinely broken boot-sector code still won't boot, and skipping the reinstall step because "it was probably fine anyway" is exactly the kind of assumption that causes a second failed reboot.

---

## Step 1: Recognize the Symptom

```text
error: no such device: ...
error: unknown filesystem.
Entering rescue mode...
grub>
```

A bare `grub>` prompt with no selectable menu — as opposed to a menu that displays but whose default entry then fails — points at GRUB's own early startup failing before it could even build a menu. That's a strong signal the problem is GRUB's own configuration or installed files, not something one layer further into the boot process (which is what Module 1's fstab scenario looks like instead).

---

## Step 2: Manually Locate the Boot Partition (the Real, Physical-Access Technique)

If you were standing at the console of a machine actually stuck at this bare prompt, GRUB's own built-in shell gives you enough to get back in for one boot, entirely by hand:

```text
grub> ls
(hd0) (hd0,gpt2) (hd0,gpt1)

grub> ls (hd0,gpt2)/
lost+found/ grub/ vmlinuz-6.8.0... initrd.img-6.8.0....img ...
```

`ls` alone lists available device names in GRUB's own naming convention; `ls (hd0,gptN)/` lists that partition's contents. Iterating through candidates until you find one containing recognizable boot artifacts (`vmlinuz-*`, `initrd.img-*`, a `grub/` directory) is how you find the right partition with zero prior assumptions about disk layout — which matters exactly because the config that would normally have told you this is what's missing.

```text
grub> set root=(hd0,gpt2)
grub> linux (hd0,gpt2)/vmlinuz-6.8.0-... root=/dev/vda1
grub> initrd (hd0,gpt2)/initrd.img-6.8.0-...img
grub> boot
```

`set root=` tells GRUB's current session which partition subsequent bare paths are relative to. `linux` specifies the kernel and its command line (critically the real `root=` device). `initrd` specifies the matching initramfs — mismatch the versions between the two and the boot commonly fails or drops to its own emergency shell. `boot` starts this manually-assembled configuration.

**This gets the system running for one session — and that's all it does.** Nothing about this sequence is written to disk. The moment the machine reboots, GRUB starts fresh from whatever broken state caused the rescue prompt in the first place. This is precisely why the earlier "one-shot manual boot is not a fix" framing matters, and it's also precisely the part of this technique that a purely SSH-driven grading harness cannot exercise — there is no console to type `ls`/`set root`/`linux`/`initrd`/`boot` into. Know this sequence for the exam regardless; the hands-on portion of this lab picks up at the next step, which is identical whether you reached a working shell this way or (as in this lab) the VM's current boot simply already succeeded on its own.

---

## Step 3: Reinstall GRUB to the Disk

```bash
sudo grub-install /dev/vda
```

(RHEL/openSUSE-family: `sudo grub2-install /dev/vda` — same underlying tool, different package/command naming convention.)

Confirm the target device with `lsblk` before running this — `grub-install` writes directly to a disk's boot sector or EFI partition, and it deserves the same fresh identity check any disk-level write command does. Check whether this system boots BIOS/legacy or UEFI before assuming the invocation above is correct:

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS/legacy"
```

On a UEFI system, the invocation targets the EFI system partition rather than a raw disk device, typically:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

This step is what actually fixes "GRUB's own code is missing or corrupted on disk" at its root. Without it, the very next reboot returns to the same broken state, since a manual console boot (Step 2) never touches the disk at all.

---

## Step 4: Regenerate a Fresh Configuration

```bash
sudo update-grub
```

(RHEL/openSUSE-family: `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`.)

This rebuilds the actual menu — scanning installed kernels and `/etc/default/grub` settings — into a fresh `grub.cfg`, the exact file Step 3's reinstalled GRUB code will read and present on the next real, unassisted reboot.

```bash
ls -l /boot/grub/grub.cfg
```

Confirm the file exists, is non-empty, and carries a fresh timestamp.

---

## Step 5: Confirm the Repair Is Durable

```bash
sudo grub-install --recheck /dev/vda
```

`--recheck` reports success (or an error naming exactly what's still wrong) without needing an actual reboot to find out — the closest thing to "prove it before you bet on it" that this particular repair offers over SSH.

```bash
grep -c menuentry /boot/grub/grub.cfg
```

A non-zero count confirms the regenerated config actually contains bootable entries, not just an empty shell of a file.

On a real machine, the final, genuine confirmation is still a real reboot — watching the console to see a normal menu appear (or a normal unassisted boot, depending on configured timeout) with no manual intervention required. This lab's grading stops short of that final reboot, since forcing one is outside what an SSH-only harness can safely orchestrate — but every command up to that point is the identical, real repair you'd run on a genuinely broken machine.

---

## Self-Check and Verification

1. **Bare prompt vs. broken entry:** A machine shows a full GRUB menu, but the highlighted default entry fails to boot. Is that the same failure category this module addresses? *(Answer: No — a menu that appears at all means GRUB's own config was readable; a failing entry inside it points at something more contained, like a bad kernel/initrd reference, not GRUB's own installed code being broken.)*
2. **Two tools, two jobs:** After running `grub-install` successfully, is the system's boot menu automatically up to date with every currently installed kernel? *(Answer: No — `grub-install` only rewrites the boot-sector/EFI code; the menu itself still needs `update-grub`/`grub-mkconfig` run separately to reflect current kernels and settings.)*
3. **Persistence of a manual boot:** You manually assemble and boot a system from the bare `grub>` prompt using `set root`/`linux`/`initrd`/`boot`, and it comes up fine. Does the next reboot also succeed without help? *(Answer: No — nothing about that manual sequence is written to disk; the next reboot starts from the same broken state unless `grub-install` (and `update-grub`) are run once you're actually in.)*
