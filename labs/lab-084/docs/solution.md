# Solution Walkthrough

This lab's "broken bootloader" is staged directly on your primary VM's own disk — safely, because only `/boot/grub/grub.cfg` was removed. GRUB's own installed boot-sector/EFI code, and the kernel your **current** session already booted from, were never touched. Every command below is the genuine repair; nothing here is a simulation aimed at a stand-in disk.

---

## Step 1: Confirm the Symptom

```bash
ls -l /boot/grub/grub.cfg
```

```text
ls: cannot access '/boot/grub/grub.cfg': No such file or directory
```

This is the on-disk equivalent of a machine that would drop to a bare `grub>` rescue prompt on its next boot: GRUB's own menu configuration is simply gone. Your SSH session staying alive right now is not evidence this is fine — it only proves the **current** boot, which already happened before this file went missing, is unaffected.

---

## Step 2: Determine the Firmware/Boot Mode

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS/legacy"
```

`grub-install`'s correct invocation genuinely differs between the two — a BIOS-style invocation on a UEFI system (or vice versa) is a classic, easy-to-make mistake worth ruling out before touching anything.

---

## Step 3: Identify the Primary Disk

```bash
lsblk -f
findmnt -no SOURCE /
```

```text
NAME    FSTYPE   UUID                                 MOUNTPOINT
vda
└─vda1  ext4     1a2b3c4d-...                          /
```

`findmnt -no SOURCE /` gives the exact partition backing your root filesystem (e.g. `/dev/vda1`); strip the partition number to get the whole-disk device `grub-install` needs (`/dev/vda`). Your actual device letter may differ — substitute your own from here on, and confirm it with `lsblk` before running anything that writes to a disk.

---

## Step 4: Reinstall GRUB's Boot-Sector/EFI Code

BIOS/legacy:

```bash
sudo grub-install /dev/vda
```

UEFI:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

This writes GRUB's actual boot-sector or EFI executable code — the very first, tiny program the firmware hands control to before anything else exists. A config regenerated on top of a machine that skipped this step still would not boot; this is the step that matters most, and the one most guides skip past too quickly.

---

## Step 5: Regenerate a Fresh grub.cfg

```bash
sudo update-grub
```

`update-grub` is Ubuntu's thin wrapper around `grub-mkconfig -o /boot/grub/grub.cfg` — same underlying machinery, distro-specific output path already baked in. It scans installed kernels and `/etc/default/grub` settings and writes a fresh menu configuration to exactly the path GRUB's reinstalled code (Step 4) will read on the next real, unassisted reboot.

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
```

Confirm the file exists, carries a fresh timestamp, and its `menuentry` count is non-zero — not just an empty shell of a file.

---

## Step 6: Confirm the Repair Is Durable

```bash
sudo grub-install --recheck /dev/vda        # or the --target=x86_64-efi form on UEFI
```

`--recheck` reports success (or an error naming exactly what's still wrong) without needing an actual reboot to find out — the closest thing to "prove it before you bet on it" this repair offers over SSH.

---

## Verification

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
sudo grub-install --recheck /dev/vda
```

Once verified, run the local validation suite to pass the lab.

---

## A Note on the Real, Physical Technique

On a real machine actually stuck at a bare `grub>` rescue prompt, Steps 1–3 above would instead start with GRUB's own built-in shell: `ls` to list devices in GRUB's own naming scheme, `ls (hd0,gptN)/` to find the partition holding `/boot`, then `set root=`, `linux`, `initrd`, and `boot` to manually assemble and boot the installed system for one session. That manual sequence lives only in GRUB's in-memory session state — nothing about it is written to disk, so the moment the machine reboots it starts fresh from the same broken state. Steps 4–6 above are exactly what you'd run once back in that way (or via `chroot` from external rescue media, using the same bind-mount mechanics as Module 1's fstab-repair lab) — this lab's grading picks up at that identical point, since this VM's current boot simply already succeeded on its own.
