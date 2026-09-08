# Part 3 — chroot in, fix, prove, unmount

> Prerequisite: [Part 2 — Mount the broken root, and get the tools in](./course-02-mount-and-get-tools-in.md). Next: [Section 080 quiz](../quiz.md).

The chroot is assembled. Now enter it, correct the one bad line against reality, prove the fix with `mount -a` *before* any reboot, and unmount in the right order. The core discipline of the whole technique lives in "prove it inside the chroot first".

## chroot in, and confirm where you are

```bash
# shell: the repair host, root
sudo chroot /mnt/repair /bin/bash
```

`man chroot`: this changes the apparent root directory for this process and its children to `/mnt/repair`, then runs the command. Every path now resolves against the target's tree.

```bash
cat /etc/hostname
# data-001        ← the target's hostname, not the repair host's — you are inside
```

## Find and fix the broken line

```bash
cat /etc/fstab
```

```text
UUID=aabbccdd-5555-6666-7777-8888dead  /data  ext4  defaults  0  2
```

Cross-reference every device identifier against reality, from inside the chroot:

```bash
blkid
```

Say `blkid` shows the real UUID ends `888899990000`, not `8888dead`. That mistyped UUID is the entire outage — the single most common real cause of this failure. Fix it:

```bash
sed -i 's/aabbccdd-5555-6666-7777-8888dead/aabbccdd-5555-6666-7777-888899990000/' /etc/fstab
```

A bad entry sometimes pairs with a missing mount point:

```bash
mkdir -p /data
```

## Prove the fix — before you reboot

```bash
mount -a
echo $?
```

`mount -a` mounts everything in the chroot's `/etc/fstab` that is not already mounted — **the same check systemd performs during boot**, but runnable on demand with a clear exit code instead of a hung boot to diagnose blind. Exit `0`, no output → every entry as written is mountable.

```bash
df -h /data     # confirm the corrected entry actually mounted
```

**This is the discipline of the whole technique: prove the fix inside the chroot first.** A second failed reboot after a rushed, unverified edit compounds the outage — now you debug the original problem *and* whatever the rushed fix broke.

If the failure had also touched GRUB or the initramfs (not a pure fstab typo), regenerate them **from inside the chroot**, because they must reference the target's kernel and config, not the rescue environment's:

```bash
update-grub && update-initramfs -u        # Debian/Ubuntu
grub2-mkconfig -o /boot/grub2/grub.cfg && dracut --force   # RHEL/openSUSE
```

## Exit and unmount in reverse order

```bash
exit                    # leave the chroot
sudo umount /mnt/repair/data     # anything mounted *inside* the chroot first
sudo umount /mnt/repair/dev /mnt/repair/proc /mnt/repair/sys
sudo umount /mnt/repair/lib64 2>/dev/null
sudo umount /mnt/repair/lib /mnt/repair/sbin /mnt/repair/bin /mnt/repair/usr
sudo umount /mnt/repair          # the target root last
```

Unmount in the **reverse order of mounting** — you cannot unmount a filesystem that still has something mounted inside it. `sudo umount -R /mnt/repair` does the same in one command, worth knowing once the individual steps are second nature.

On a real system this is where you reboot and confirm unassisted boot. In the lab the corrected `/etc/fstab` sitting on the disk is the proof.

> [!WARNING]
> - **Editing `/etc/fstab` and rebooting without `mount -a`** → a second failed boot; now two problems to debug. Always prove it in the chroot.
> - **Trusting a syntactically valid UUID** → well-formed ≠ correct. Cross-check against `blkid` every time.
> - **Running `update-grub` / `dracut` outside the chroot** → it targets the rescue environment's kernel, not the broken system's.
> - **Unmounting `/mnt/repair` before the binds inside it** → "target is busy". Reverse order, or `umount -R`.

> *`chroot` in, cross-check the bad `fstab` UUID against `blkid`, `sed` the fix, `mkdir -p` any missing mount point, then `mount -a; echo $?` (`0` = mountable, the same check boot does) before rebooting — and unmount inner mounts before the target root, or use `umount -R`.*

## Reference

- `man chroot` — changing the apparent root; running a shell inside it.
- `man mount` — `mount -a`, `/etc/fstab` semantics; the exit code meanings.
- `man umount` — `-R` recursive unmount and why order matters otherwise.
