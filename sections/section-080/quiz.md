# Section 080 Knowledge Check: System Disaster Recovery

Test your understanding of chroot-based repair, password recovery without rescue media, partition table backup/restore, and GRUB reinstallation.

---

## Scenario-Based Questions

### Question 1
You mount a broken system's root partition at `/mnt/sysroot` and immediately run `sudo chroot /mnt/sysroot /bin/bash`, skipping straight past any further setup. Inside the chroot, `blkid` prints nothing at all, even though you know the disk has partitions with real UUIDs. What's the cause, and what should you have done first?
*   **A)** `blkid` is broken inside every chroot by design; you must exit and run it on the host instead.
*   **B)** You forgot to bind-mount `/dev`, `/proc`, and `/sys` into `/mnt/sysroot` before chrooting in, so `/dev` inside the chroot is an empty directory with no device nodes for `blkid` to read.
*   **C)** The root partition was mounted read-only, which blocks `blkid` from functioning.
*   **D)** `chroot` requires a `--bind-dev` flag that was omitted.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** A bare chroot has no populated `/dev`, `/proc`, or `/sys` — those need to be explicitly bind-mounted in (`mount --bind /dev /mnt/sysroot/dev`, and likewise for `/proc` and `/sys`) before chrooting. Without that step, tools that depend on device nodes, kernel state, or process information fail in ways that look unrelated to the missing binds — `blkid` returning nothing despite real partitions existing is a textbook symptom.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `blkid` works fine inside a properly-prepared chroot; it is not disabled by design.
    *   *Option C* is incorrect because a read-only mount doesn't stop `blkid` from reading device metadata — `blkid` doesn't need write access to report what it finds.
    *   *Option D* is incorrect because `chroot` has no such flag; bind-mounting is a separate `mount` operation performed before the chroot, not a chroot option.
</details>

---

### Question 2
Inside a chroot, you've just corrected a mistyped UUID in `/etc/fstab`. What is the single command that proves this fix actually works, without needing to reboot to find out — and what does an exit code of `0` from it confirm?
*   **A)** `systemctl daemon-reload`; it confirms systemd has re-read the corrected fstab.
*   **B)** `df -h`; it confirms disk usage is being reported correctly across all filesystems.
*   **C)** `mount -a`; exit code `0` confirms every entry currently listed in that fstab is mountable — the same check a real boot's systemd performs.
*   **D)** `fsck -y /etc/fstab`; it repairs any remaining errors in the fstab file itself.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** `mount -a` attempts to mount every entry in `/etc/fstab` not already mounted and not marked `noauto`. This is functionally identical to what systemd does during a real boot, but runnable on demand with an immediate, unambiguous exit code instead of a hung boot process to diagnose blind. Exit `0` with no output means the fix is genuinely correct.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because `daemon-reload` reloads systemd unit files, not fstab mount state, and proves nothing about whether the corrected line actually mounts.
    *   *Option B* is incorrect because `df -h` only reports what's currently mounted — it won't attempt to mount the corrected entry, so it can't prove the fix works.
    *   *Option D* is incorrect because `fsck` is a filesystem checker; it does not operate on or repair `/etc/fstab`, which is a plain text configuration file, not a filesystem.
</details>

---

### Question 3
The root password on a healthy, fully-booting server is lost, and there's no other account with `sudo` access. A colleague suggests booting external rescue media, mounting the root filesystem by hand, and chrooting in to fix it. Is that the right tool for this job?
*   **A)** Yes — external rescue media is always required to change a root password, regardless of the system's boot health.
*   **B)** No — since the system boots perfectly fine on its own, a faster technique exists: interrupt GRUB for one boot, append `rd.break` or `init=/bin/bash` to the kernel line, and reset the password directly, with no external media needed at all.
*   **C)** No — root passwords cannot be reset without physically replacing the disk.
*   **D)** Yes, but only if SELinux is disabled first.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** External rescue media is the right tool when the installed system genuinely cannot boot on its own. Here, the system boots fine — only the credential is missing. A one-boot GRUB kernel-parameter edit (`rd.break` or `init=/bin/bash`) reaches a root-equivalent shell on the real system directly, without needing any external media, and is the faster, more appropriate technique for this specific failure mode.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because rescue media is not always required — it's specifically for unbootable systems, which this one is not.
    *   *Option C* is incorrect because password resets never require physical disk replacement; the data is intact, only the credential is unknown.
    *   *Option D* is incorrect because SELinux mode doesn't determine which recovery *technique* is appropriate — it only introduces an extra relabel step (`touch /.autorelabel`) after the fact if enforcing.
</details>

---

### Question 4
You're about to run risky `sgdisk` operations on a secondary GPT-partitioned disk. You take a backup with `sgdisk --backup=/root/backup.bin /dev/vdc`, then move directly to your risky partitioning work without checking anything else. Later, disaster strikes and you restore with `sgdisk --load-backup=/root/backup.bin /dev/vdc`. Partitions reappear correctly in `lsblk`. Is the disk now confirmed fully recovered?
*   **A)** Yes — partitions reappearing in `lsblk` is definitive proof the disk is fully usable again.
*   **B)** No — you should have run `sgdisk --print` against the backup file right after creating it, and separately, `lsblk` alone only confirms the partition-table layer restored; the filesystems inside still need their own check with `fsck -n` and/or a mount-and-inspect pass.
*   **C)** Yes, because `sgdisk --load-backup` automatically runs `fsck` on every restored partition before completing.
*   **D)** No — `sgdisk --load-backup` cannot restore a GPT table once `--zap-all` has been run; a fresh partition table must be created manually instead.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Two separate habits are missing here. First, verifying a backup's sanity (`sgdisk --print` against the backup file) should happen right after taking it, not left undiscovered until an emergency. Second, the partition table and the filesystems inside each partition are two separate layers — `lsblk` showing partitions reappear only proves the table layer is back; filesystem health needs its own explicit check (`fsck -n`, or a mount-and-`ls` pass) before the disk can be called truly recovered.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because partition boundaries reappearing says nothing about whether the filesystem structures inside them are intact.
    *   *Option C* is incorrect because `sgdisk --load-backup` only writes partition-table structures; it has no awareness of filesystem contents and performs no integrity checking whatsoever.
    *   *Option D* is incorrect because `--load-backup` restoring a table after `--zap-all` is exactly what it's designed to do, and works correctly as described in the scenario.
</details>

---

### Question 5
A server's console shows a bare `grub>` prompt with no menu at all on boot. After manually locating and booting the installed system once from that prompt using `ls`, `set root`, `linux`, `initrd`, and `boot`, the administrator considers the incident closed and does nothing further. What will happen on the next reboot, and what step was skipped?
*   **A)** The next reboot will succeed normally, since the manual boot sequence permanently repairs GRUB's configuration.
*   **B)** The next reboot will return to the same bare `grub>` prompt, because the manual boot sequence exists only in that session's memory; `grub-install` (to reinstall GRUB's own boot-sector/EFI code) and `update-grub`/`grub-mkconfig` (to regenerate `grub.cfg`) were never run.
*   **C)** The next reboot will succeed, but only because `linux` and `initrd` write their target paths to a persistent GRUB environment file.
*   **D)** The system will now boot directly into `rd.break` mode on every subsequent startup.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Nothing typed at the `grub>` rescue prompt is written to disk — `set root`, `linux`, `initrd`, and `boot` only configure that one in-memory boot attempt. The underlying problem (GRUB's own installed code and/or configuration missing or corrupted) is completely unaddressed until `grub-install` reinstalls the boot-sector/EFI code and `update-grub`/`grub-mkconfig` regenerates a working `grub.cfg`, both run from inside the now-booted system.
*   **Why others are incorrect:**
    *   *Option A* is incorrect because the manual rescue-prompt sequence has no persistence mechanism at all — it directly contradicts how GRUB's rescue shell works.
    *   *Option C* is incorrect because there's no such persistent environment file involved in this manual sequence; each rescue-prompt boot starts from a clean slate.
    *   *Option D* is incorrect because `rd.break` is an entirely unrelated kernel parameter from a different recovery scenario (password reset), not something the GRUB rescue prompt sequence triggers or relates to.
</details>
