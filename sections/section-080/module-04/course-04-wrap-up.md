# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about a broken launch computer: telling which GRUB repair a machine needs, getting back in from a bare `grub>` prompt, and making the repair last.

**From [Two Repairs And Reading The Symptom](./course-01-two-repairs-and-the-symptom.md):**

- `grub-install` writes GRUB's boot code. `update-grub` (Debian and Ubuntu) and `grub2-mkconfig -o` (RHEL and openSUSE) write the menu file, `grub.cfg`.
- `update-grub` is a wrapper around `grub-mkconfig -o /boot/grub/grub.cfg`.
- A bare `grub>` prompt means GRUB itself is broken. A menu whose entry fails points further along the boot.
- A full repair runs both tools.

**From [The One-Boot Rescue From grub>](./course-02-manual-rescue-from-grub.md):**

- `ls` and `ls (hd0,gptN)/` find the partition with the kernel and initrd.
- `set root=`, `linux ... root=<real root>`, `initrd` and `boot` start the system once by hand. Match the kernel and initrd versions.
- Nothing is saved. It is a way in to run the lasting repair, not the repair itself.

**From [The Durable Repair: Reinstall And Regenerate](./course-03-durable-repair.md):**

- Check `/sys/firmware/efi` first: BIOS uses `grub-install /dev/vda`, UEFI uses `grub-install --target=x86_64-efi --efi-directory=/boot/efi`.
- Then run `update-grub` (or `grub2-mkconfig -o /boot/grub2/grub.cfg`).
- Check with `grub-install --recheck` and a non-zero `grep -c menuentry /boot/grub/grub.cfg` before you reboot.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [GRUB Corruption Recovery Lab](./labs/lab-01/README.md) | The Durable Repair: Reinstall And Regenerate | Reinstalled GRUB's boot code and wrote a fresh `grub.cfg` with real menu entries before the next reboot |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What does <code>grub-install</code> write, and what does <code>update-grub</code> write?</summary>

`grub-install` writes GRUB's own boot code, to the disk's boot area on BIOS or to the EFI system partition on UEFI. `update-grub` writes the menu file `/boot/grub/grub.cfg`.
</details>

<details>
<summary>2. A machine shows a full GRUB menu, but the default entry fails to boot. Is GRUB broken?</summary>

No. GRUB read its configuration, so the problem is further along: a wrong kernel or initrd in the entry, or a later failure such as a bad `/etc/fstab` line.
</details>

<details>
<summary>3. You booted by hand from <code>grub></code> and the system is running. What happens on the next reboot if you do nothing else?</summary>

It stops at the same `grub>` prompt. The typed orders lived only in GRUB's memory. You must run `grub-install` and `update-grub` to fix it.
</details>

<details>
<summary>4. In <code>linux (hd0,gpt2)/vmlinuz-... root=/dev/vda1</code>, what is the difference between GRUB's root and <code>root=/dev/vda1</code>?</summary>

GRUB's root, set with `set root=(hd0,gpt2)`, is where GRUB reads files. `root=/dev/vda1` is passed to the kernel and says which filesystem to mount as `/`.
</details>

<details>
<summary>5. How do you tell whether to use the BIOS or the UEFI form of <code>grub-install</code>?</summary>

Check whether `/sys/firmware/efi` exists. If it does, the machine started with UEFI; if not, it started with BIOS.
</details>

<details>
<summary>6. After <code>update-grub</code>, how do you check the new file is not empty of entries?</summary>

Run `grep -c menuentry /boot/grub/grub.cfg`. A number above zero means it has bootable entries.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-084
```

Then run `astrona list` again to check that everything is gone.
