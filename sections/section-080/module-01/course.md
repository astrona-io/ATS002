# Root-Filesystem Repair via chroot

A single bad line in `/etc/fstab` is one of the fastest ways to turn a running server into one that will not boot. On the next startup, systemd reads that file, tries to satisfy every mount it lists, hangs waiting on the one that can never succeed, and eventually drops to an emergency shell instead of finishing the boot. The system is not damaged — every file is exactly where it was — but nothing is reachable, because the one piece of configuration that tells the kernel "here is what to mount, and where" is wrong.

Recovering from this does not involve reinstalling anything. It involves getting *into* the broken system's own filesystem from the outside, running its own tools against its own configuration, fixing the one bad line, and proving the fix works — all before you dare reboot into it for real. That technique is called a **chroot repair**, and it is one of the most important muscle-memory skills in this entire domain.

---

## A Note on How This Section Is Built

Before we go further, an honest word about how this module — and the three that follow it — actually run in your lab environment, because it matters for how you should think about what you are practicing.

The lab harness that grades your work in this course does exactly one thing to check your progress: it connects to your virtual machine over SSH and runs a validation script. That is the entire mechanism. It cannot watch a physical console, it cannot type into an interactive GRUB menu, and it cannot recover if the machine genuinely stops responding to SSH. A real chroot-repair scenario, on real hardware or a real VM you're sitting in front of, starts with the machine being *unreachable* — that is the whole premise. Those two facts are in direct conflict, and it is worth being upfront about how this section resolves it rather than pretending the conflict doesn't exist.

The resolution: your lab VM's own root filesystem and boot process are never touched. Instead, bootstrap attaches a **second, disposable virtual disk** to the VM, and builds a small standalone filesystem on it — its own `/etc/fstab`, its own `/etc/shadow`, its own directory tree — representing "the broken system" in the story. Your primary VM stays fully healthy and fully reachable over SSH for the entire lab. Your job is to mount that second disk, bind-mount the tools you need into it, `chroot` into it, and perform the exact same repair sequence a real incident would demand — just aimed at a stand-in disk instead of the machine you're actually sitting on.

Every mechanical step you practice — identifying the right partition, bind-mounting `/dev`/`/proc`/`/sys`, chrooting in, editing the broken config, proving the fix with `mount -a`, unmounting cleanly — is identical to the real thing. The only difference is which disk you're aiming it at, and that difference exists purely so the lab stays gradable. On the exam, and in a real incident, you'll aim this same sequence at a genuinely unbootable machine's real root partition instead of a lab stand-in. The skill transfers completely; only the safety rail is new.

---

## The Filing Cabinet That Lost Its Labels

Picture your server's storage as a large filing cabinet full of folders — one folder per filesystem the machine needs: the root folder, a data folder, maybe a separate boot folder. Each drawer has a label on it saying exactly which folder goes where, and `/etc/fstab` is the master list of those labels: "drawer 3 goes in slot A, drawer 7 goes in slot B."

Now imagine someone updates that master list by hand, meaning to add a new drawer, and mistypes the drawer's serial number. The next time the building's automated retrieval system runs down the list, it reaches that one bad entry, tries to find a drawer that doesn't exist, and simply stops — refusing to continue past an instruction it cannot fulfill, even though every other drawer is sitting right there, perfectly intact, waiting to be filed. That is precisely what a bad `fstab` entry does to a boot sequence: systemd is a very literal retrieval system, and it will not skip past an instruction it cannot complete.

The fix is not to search the whole building for missing folders — nothing is missing. The fix is to correct the one wrong serial number on the master list. But to edit that list, you need physical access to the cabinet from *outside* the automated system that's currently stuck — which is exactly what booting into a rescue environment and mounting the drawers by hand gives you.

---

## Reaching a Shell on the Broken System

In a real incident, there are two ways to reach a shell that can see the broken system's disks without needing that system's own (currently failing) boot sequence to succeed:

**If the bootloader is accessible and healthy**, you can interrupt it and boot the installed system straight into a minimal systemd target instead of a full boot, by appending a kernel parameter at the GRUB menu:

```
systemd.unit=rescue.target
```

`rescue.target` mounts local filesystems and gives you a shell, without needing every service (including the one hanging on the bad mount) to succeed first. `emergency.target` is even more minimal and may not mount local filesystems at all, meaning more manual work once you're in.

**If the bootloader itself is inaccessible or broken**, external rescue or live media is the fallback — the remaining steps from here on are identical either way, because both paths land you at a shell that can see the target system's disks, just not running the target system's own (broken) boot sequence.

In this lab, neither of those is necessary, because your primary VM was never actually broken — you're simply working from its own healthy, always-on shell over SSH, treating the second disk as the thing that needs repair.

---

## Step 1: Identify the Right Partitions

Never assume a device name. `lsblk -f` shows every block device together with its filesystem type, label, and UUID in one view:

```bash
lsblk -f
```

```text
NAME    FSTYPE   LABEL         UUID                                 MOUNTPOINT
vda
└─vda1  ext4                   1a2b3c4d-...                         /
vdb
├─vdb1  ext4     DATA001ROOT   9f8e7d6c-1111-2222-3333-444455556666
└─vdb2  ext4     DATA001VOL    aabbccdd-5555-6666-7777-888899990000
```

Cross-check against `blkid` if you want the same information from a different angle:

```bash
sudo blkid
```

The label makes intent obvious here (`DATA001ROOT`, `DATA001VOL`), but in a real incident you may only have UUIDs and disk geometry to go on — which is exactly why `lsblk -f`'s combined view, rather than guessing from a bare device name like `/dev/sdb1`, is the habit worth building.

---

## Step 2: Mount the Broken Root — Then Get the Tools In

```bash
sudo mkdir -p /mnt/repair
sudo mount /dev/vdb1 /mnt/repair
```

An empty `/mnt/repair` is not enough to chroot into usefully. A bare chroot has no `bash`, no `mount`, no `blkid` — none of the tools you actually need — because this stand-in disk only carries the *configuration* that's broken, not a full duplicate operating system. So before chrooting in, we bind-mount the primary VM's own real userland into it, read-only, alongside the target disk's own `/etc`:

```bash
sudo mount --bind /usr /mnt/repair/usr
sudo mount --bind /bin /mnt/repair/bin
sudo mount --bind /sbin /mnt/repair/sbin
sudo mount --bind /lib /mnt/repair/lib
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
```

`man mount`'s `--bind` option describes exactly what's happening: a bind mount does not create a new filesystem — it re-attaches an *already-mounted* directory tree at a second location. Nothing is copied; `/mnt/repair/usr` becomes a second doorway into the exact same files already living under the primary VM's own `/usr`. This gives the chroot a working `bash`, `mount`, `sed`, `blkid`, and everything else it needs, while `/mnt/repair/etc` — the part that actually matters for this repair — stays exactly what's on the target disk, broken fstab and all.

Then bind-mount the three trees every chroot repair needs, exactly as a real recovery would:

```bash
sudo mount --bind /dev /mnt/repair/dev
sudo mount --bind /proc /mnt/repair/proc
sudo mount --bind /sys /mnt/repair/sys
```

> This is the step most guides skip, and it's exactly why: without a populated `/proc` (process/mount information), `/sys` (kernel/device state), and `/dev` (device nodes), tools running inside the chroot fail in ways that look completely unrelated to the missing bind mounts — `blkid` finding nothing, `mount` unable to resolve a UUID at all. If something inside a chroot fails mysteriously, check these three binds first.

---

## Step 3: chroot In

```bash
sudo chroot /mnt/repair /bin/bash
```

`man chroot` describes this plainly: it changes the apparent root directory for the current process (and its children) to the given path, then runs the given command inside that new root. From this point on, every path you reference resolves against `/mnt/repair`'s tree, not the primary VM's own root.

Confirm you're really inside the target system, not still looking at the primary VM:

```bash
cat /etc/hostname
# data-001
```

---

## Step 4: Find and Fix the Broken Line

```bash
cat /etc/fstab
```

```text
# /etc/fstab: static file system information for data-001
UUID=aabbccdd-5555-6666-7777-8888dead  /data  ext4  defaults  0  2
```

Cross-reference every device identifier against reality, from inside the chroot:

```bash
blkid
```

Suppose `blkid` shows the actual data volume's UUID is `aabbccdd-5555-6666-7777-888899990000` — the fstab line above is close, but the last four characters were mistyped as `dead` instead of the real ending. That is the entire outage: one stale or mistyped UUID, the single most common real-world cause of this exact failure mode. Fix it:

```bash
sed -i 's/aabbccdd-5555-6666-7777-8888dead/aabbccdd-5555-6666-7777-888899990000/' /etc/fstab
```

Confirm the mount point directory itself actually exists — a bad fstab entry sometimes pairs with a missing directory too:

```bash
mkdir -p /data
```

---

## Step 5: Prove the Fix — Before You Ever Reboot

```bash
mount -a
echo $?
```

`mount -a` attempts to mount everything currently listed in the chroot's own `/etc/fstab` that isn't already mounted — functionally the same check systemd performs during a real boot, just runnable on demand with a clear exit code instead of a hung boot process to diagnose blind. Exit code `0` and no output means every fstab entry as currently written is mountable.

```bash
df -h /data
# confirms the corrected entry actually mounted
```

This is the core discipline of the entire lab: **prove the fix works inside the chroot first.** A second failed reboot after a rushed, unverified fix compounds the original outage — now you're debugging both the original problem and whatever the rushed fix broke.

If the underlying failure had also touched GRUB configuration or the initramfs rather than being a pure fstab typo, this is also the point where you would regenerate them — `update-grub` and `update-initramfs -u` on Debian/Ubuntu-family systems, `grub2-mkconfig` and `dracut --force` on RHEL/openSUSE-family systems — run from inside the chroot specifically, because they need to reference the target system's own kernel version and configuration, not the rescue environment's.

---

## Step 6: Exit and Unmount Cleanly, in Reverse Order

```bash
exit
```

```bash
sudo umount /mnt/repair/data
sudo umount /mnt/repair/dev
sudo umount /mnt/repair/proc
sudo umount /mnt/repair/sys
sudo umount /mnt/repair/lib64 2>/dev/null
sudo umount /mnt/repair/lib
sudo umount /mnt/repair/sbin
sudo umount /mnt/repair/bin
sudo umount /mnt/repair/usr
sudo umount /mnt/repair
```

Unmount in the reverse order of mounting — bind mounts and anything `mount -a` mounted inside the chroot first, the root of the target filesystem last — because you cannot unmount a filesystem that still has something mounted inside it. `sudo umount -R /mnt/repair` (recursive unmount) achieves the same end state in one command, and is worth knowing as a faster alternative once the individual steps are second nature.

On a real system, this is also the point where you would reboot and confirm the machine now boots unassisted. In this lab, the proof lives entirely on the second disk: once you exit the chroot and unmount, the corrected `/etc/fstab` is sitting there on `/dev/vdb1` for validation to check directly.

---

## Self-Check and Verification

1. **Why bind-mount before chroot?** You SSH into a fresh lab VM and chroot into a mounted disk without bind-mounting `/dev`, `/proc`, or `/sys` first. `blkid` inside the chroot returns nothing at all, even though the target disk clearly has partitions with UUIDs. Why? *(Answer: without those three bind mounts, `/dev` inside the chroot is an empty directory — there are no device nodes for `blkid` to read from, regardless of what's actually on the underlying disk.)*
2. **Diagnosing the typo:** A bad fstab line references `UUID=aabbccdd-...-8888dead`. What is the one command, run from inside the chroot, that tells you definitively whether that UUID is correct or not? *(Answer: `blkid`, cross-referenced against the fstab line — never trust that a syntactically well-formed UUID is automatically the correct one.)*
3. **Proving it before rebooting:** You've edited `/etc/fstab` inside the chroot. What single command proves the fix works without needing to reboot to find out, and what does exit code `0` from it actually confirm? *(Answer: `mount -a`; exit `0` confirms every entry currently in that fstab is mountable — the same check a real boot's systemd would perform.)*
