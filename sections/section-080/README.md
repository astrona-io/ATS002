# Section 080: System Disaster Recovery

Every other section in this domain assumes the machine in front of you basically works. This section is about the night it doesn't: a bad configuration line that stops the boot cold, a lost root password with no fallback account, a wiped partition table on a disk you can't afford to lose, and a bootloader that's missing its own installed code. None of these mean the data is gone. All of them mean you need a calm, repeatable procedure for getting back in — and the discipline to prove your fix works before you bet a reboot on it.

**A note on how this section runs.** Two of the four scenarios below — chroot fstab repair and password reset — are, in the real world, physical-console techniques: you interrupt a real GRUB menu, or boot real rescue media, on a machine that has (deliberately, for the exercise) actually stopped responding to normal login. This training platform's lab harness grades your work entirely by SSHing into your VM and running a script — it has no way to script an interactive boot menu, and no way to recover if your VM genuinely goes unreachable. So rather than skip those two mechanics, every lab in this section re-stages them safely: your primary VM stays fully healthy and reachable over SSH at all times, and a small, disposable second disk (or, for the GRUB module, the VM's own next-boot configuration) stands in for "the broken thing." You practice the exact same commands, in the exact same order, against a target built specifically so a mistake costs you nothing. Each module says so plainly, right where the adaptation happens — this is how the mechanic is safely practiced in a disposable lab VM, not a shortcut hidden from you.

---

## What You Will Master

By completing this section, you will acquire four core recovery capabilities:
*   **chroot-Based Root Repair:** How to mount a broken system's filesystem from outside its own (failing) boot sequence, bind-mount `/dev`, `/proc`, and `/sys` into it, `chroot` in, and fix a bad `/etc/fstab` entry — then prove the fix with `mount -a` before ever rebooting.
*   **Credential Recovery Without Rescue Media:** How to interrupt GRUB for a single boot, reach a root-equivalent shell via `rd.break` or `init=/bin/bash`, and reset a lost root password on a system that otherwise boots perfectly fine.
*   **Partition Table Backup & Restore:** How to back up a GPT partition table with `sgdisk --backup` before doing anything risky, verify that backup is sane, and restore it cleanly after a disaster — while treating partition-table health and filesystem health as two separate, separately-verified layers.
*   **GRUB Bootloader Reinstallation:** How to recognize a genuinely broken GRUB installation (a bare `grub>` rescue prompt, not just a bad menu entry), reinstall GRUB's own boot-sector or EFI code with `grub-install`, and regenerate a working `grub.cfg` with `update-grub`.

---

## The Learning & Lab Path

This section is divided into four focused modules, each paired with a dedicated hands-on practice lab, and concluded with a comprehensive capstone challenge:

### 1. Root-Filesystem Repair via chroot
*   **Module Reader:** **[Module 1: Root-Filesystem Repair via chroot](./module-01/course.md)**
    1. [Why a bad fstab stops the boot, and how to reach a shell](./module-01/course-01-why-it-wont-boot-and-reaching-a-shell.md)
    2. [Mount the broken root, and get the tools in](./module-01/course-02-mount-and-get-tools-in.md)
    3. [chroot in, fix, prove, unmount](./module-01/course-03-chroot-fix-prove-unmount.md)
*   **Practice Lab Sandboxes:**
    1. **`sections/section-080/module-01/labs/lab-01`** — a mistyped UUID in `/etc/fstab`
    2. **`sections/section-080/module-01/labs/lab-02`** — a wrong filesystem *type* in `/etc/fstab` (`ext4` where the partition is `xfs`)
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Mount a disposable second disk representing a broken system's root filesystem, bind-mount `/dev`, `/proc`, and `/sys` into it, `chroot` in, fix a mistyped UUID in `/etc/fstab`, and prove the fix with `mount -a`.

### 2. Password Reset & Single-User Recovery
*   **Module Reader:** **[Module 2: Password Reset & Single-User Recovery](./module-02/course.md)**
    1. [Two doors — rd.break and init=/bin/bash](./module-02/course-01-two-doors-rd-break-and-init.md)
    2. [The chroot equivalent, and editing /etc/shadow directly](./module-02/course-02-chroot-equivalent-and-shadow-edit.md)
*   **Practice Lab Sandbox:** **`sections/section-080/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Practice the chroot-based half of the real recovery mechanic — mount a disposable disk representing a locked-out system, chroot in, and reset the root account's password hash in `/etc/shadow`.

### 3. Partition Table Backup & Recovery
*   **Module Reader:** **[Module 3: Partition Table Backup & Recovery](./module-03/course.md)**
    1. [Two layers, not one, and identifying the target disk](./module-03/course-01-two-layers-and-identifying-the-disk.md)
    2. [Back up the partition table, and verify the backup](./module-03/course-02-backup-and-verify.md)
    3. [Simulate, restore, and verify both layers](./module-03/course-03-simulate-restore-verify.md)
*   **Practice Lab Sandbox:** **`sections/section-080/module-03/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-03/labs/lab-01
    ```
*   **Hands-on Objective:** Back up a secondary GPT disk's partition table with `sgdisk --backup`, verify the backup, wipe the table with `sgdisk --zap-all`, restore it with `sgdisk --load-backup`, and confirm the filesystems inside are still intact.

### 4. GRUB Corruption Recovery
*   **Module Reader:** **[Module 4: GRUB Corruption Recovery](./module-04/course.md)**
    1. [Two repairs, easy to confuse, and reading the symptom](./module-04/course-01-two-repairs-and-the-symptom.md)
    2. [The one-boot manual rescue from grub>](./module-04/course-02-manual-rescue-from-grub.md)
    3. [The durable repair — reinstall and regenerate](./module-04/course-03-durable-repair.md)
*   **Practice Lab Sandbox:** **`sections/section-080/module-04/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-04/labs/lab-01
    ```
*   **Hands-on Objective:** Recover from a missing `/boot/grub/grub.cfg` on a VM whose next reboot would otherwise fail — reinstall GRUB's boot-sector code with `grub-install` and regenerate a fresh, working configuration with `update-grub`.

### 5. Section Capstone Challenge
*   **Comprehensive Challenge:** **`sections/section-080/capstone/labs/lab-01` (System Disaster Recovery Integration)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** A bad night on call. Restore a secondary disk's partition table from an existing backup and confirm its filesystems survived, then reinstall and regenerate a stale GRUB configuration on the primary disk before the next scheduled reboot happens.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the practical lab missions:

*   **[Take the Section 080 Knowledge Check Quiz](./quiz.md)**
