# Solution Walkthrough

The broken bootloader is set up directly on your training ship's own disk. That is safe because only `/boot/grub/grub.cfg` was removed. GRUB's installed boot code and the kernel your current session booted from were not touched. Every command below is the real repair; nothing is aimed at a stand-in disk.

---

## Step 1: Confirm the symptom

```bash
ls -l /boot/grub/grub.cfg
```

```text
ls: cannot access '/boot/grub/grub.cfg': No such file or directory
```

This is the on-disk version of a machine that would stop at a bare `grub>` prompt on its next boot: GRUB's launch checklist is gone. Your SSH session working right now does not mean all is well. It only proves that the current boot, which finished before the file went missing, is unaffected.

---

## Step 2: Find the firmware type

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS/legacy"
```

The kernel creates `/sys/firmware/efi` only on machines started by UEFI firmware. The right `grub-install` command differs between the two. Using the BIOS form on a UEFI machine, or the other way round, is a classic mistake, so rule it out before you write anything.

---

## Step 3: Identify the primary disk

```bash
lsblk -f
findmnt -no SOURCE /
```

```text
NAME    FSTYPE   UUID                                 MOUNTPOINT
vda
└─vda1  ext4     1a2b3c4d-...                          /
```

This output is shortened and its UUID is made up. On Ubuntu 24.04 the main disk usually has more partitions, for example a separate `/boot` and an EFI partition, and `lsblk -f` shows a few more columns.

`findmnt -no SOURCE /` prints the partition behind your root filesystem, for example `/dev/vda1`. Remove the partition number to get the whole disk that `grub-install` needs on BIOS: `/dev/vda`. Your device name may differ. Use your own, and confirm it with `lsblk` before running anything that writes to a disk.

---

## Step 4: Reinstall GRUB's boot code

BIOS/legacy:

```bash
sudo grub-install /dev/vda
```

UEFI:

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

The UEFI form above is for 64-bit Intel and AMD machines. If your training ship runs on an ARM computer, the target is `arm64-efi` instead.

This writes GRUB's boot code, the first tiny program the firmware runs. It also rewrites GRUB's core image under `/boot/grub` (`core.img` on BIOS, `core.efi` on UEFI), which is how the grader knows you ran it. A new `grub.cfg` on a machine that skipped this step would not help if the boot code were damaged.

---

## Step 5: Write a fresh grub.cfg

```bash
sudo update-grub
```

`update-grub` is Ubuntu's short wrapper around `grub-mkconfig -o /boot/grub/grub.cfg`. It scans the installed kernels and the settings in `/etc/default/grub`, and writes a new menu file to the exact path the reinstalled boot code reads on the next real boot.

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
```

Confirm that the file exists, has a fresh timestamp, and that its `menuentry` count is above zero, so it is not just an empty shell.

---

## Step 6: Check the repair

```bash
sudo grub-install --recheck /dev/vda        # or the --target=x86_64-efi form on UEFI
```

`--recheck` makes `grub-install` throw away its old map of the disks, look at them again and install once more. A run that ends with `No error reported` shows GRUB can find the disk and write its code, without a reboot. An error message names what is still wrong.

---

## Verification

```bash
ls -l /boot/grub/grub.cfg
grep -c menuentry /boot/grub/grub.cfg
sudo grub-install --recheck /dev/vda
```

When all three look right, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/module-04/labs/lab-01
```

---

## The real console technique

On a real machine stuck at a bare `grub>` prompt, the work before Step 4 starts in GRUB's own shell instead. `ls` lists the devices in GRUB's naming, and `ls (hd0,gptN)/` finds the partition that holds the kernel and initrd. Then `set root=`, `linux`, `initrd` and `boot` start the installed system by hand for one session.

That hand-built boot lives only in GRUB's memory. Nothing is written to disk, so the next reboot starts from the same broken state. Steps 4 to 6 are exactly what you run once you are back in that way, or through a chroot from rescue media with `/dev`, `/proc` and `/sys` bind-mounted. This lab picks up at that same point, because your ship's current boot already succeeded on its own.
