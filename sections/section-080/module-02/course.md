# Password Reset & Single-User Recovery

Module 1 covered a genuinely unbootable system — GRUB and the kernel work fine, but a bad `fstab` entry stops systemd from ever finishing startup. Losing the root password is a completely different kind of problem: the system boots *perfectly*. Every service starts, every filesystem mounts, the login prompt appears right on schedule. The only thing missing is proof of identity — and there's no other privileged account to `sudo` from to fix it. Reaching for full rescue media here would work, but it is overkill: a much faster technique exists that needs no external media at all, because the machine you're trying to get into is already healthy and already sitting right there.

The technique: interrupt the bootloader for a single boot, edit the kernel command line for that one boot only, and land in a shell on the real system with root-equivalent access before any login prompt ever appears. Nothing about the edit gets saved anywhere — you're borrowing one boot cycle, not repairing anything.

---

## Two Doors Into the Same Building

Think of a normal boot as a building with a strict entry procedure: security checks your badge (login), then a series of doors open in sequence as systems come online. `rd.break` and `init=/bin/bash` are two different ways to slip in through a maintenance entrance *before* that procedure starts — but they open at two different points along the hallway, and that difference matters for what you have to do once you're inside.

**`rd.break`** interrupts inside the **initramfs** — the small, temporary root filesystem the kernel uses just long enough to find and prepare the *real* root filesystem. You land here *before* the real root has been switched to as `/`. It's visible, but only mounted (read-only) under `/sysroot` — one more step (a `chroot`) away from actually being "in."

**`init=/bin/bash`** skips the kernel's normal init process entirely and runs `/bin/bash` directly as PID 1, but only *after* the real root filesystem is already mounted as `/`. You land further down the hallway, already standing on the real filesystem, with no separate chroot step needed — though it's very likely still read-only, since flipping it to read-write is normally systemd's job, and no systemd ever ran in this path.

Both get you to a root shell on the real disk before any password is ever checked. Which one is "correct" depends only on which one a given distribution's boot sequence supports cleanly — knowing both, and knowing what's different about where each lands you, is the actual skill.

---

## The rd.break Approach

At the GRUB menu, highlight the entry and press `e` to edit it temporarily. Find the line beginning `linux` (or `linuxefi`/`linux16`) and append:

```
linux   /boot/vmlinuz-... root=/dev/mapper/... rd.break
```

Boot it (`Ctrl-X` or `F10`). You land in the initramfs's own minimal shell, with the real root available but only at `/sysroot`, read-only:

```bash
mount -o remount,rw /sysroot
chroot /sysroot
```

`man mount`'s `remount` option flips flags on an already-mounted filesystem in place — read-only to read-write — without a full unmount/mount cycle. `chroot /sysroot` then makes that filesystem the effective root, so the next command actually operates on the real system's `/etc/shadow`, not the initramfs's own throwaway filesystem:

```bash
passwd root
```

Set the new password, then back out in two steps:

```bash
exit   # leaves the chroot
exit   # continues the interrupted initramfs boot sequence
```

---

## The init=/bin/bash Approach

Same GRUB edit, different parameter, appended to the same `linux` line instead:

```
linux   /boot/vmlinuz-... root=/dev/mapper/... init=/bin/bash
```

This lands you directly on the real root filesystem — no chroot needed, since the kernel already mounted it as `/` before handing off to this shell instead of the normal init. It's likely still read-only, though:

```bash
mount -o remount,rw /
passwd root
```

Because no init process is actually running in this state — you *are* PID 1, and it's just a bare shell — a normal `reboot` won't work correctly; there's no init to receive that signal. Bring up a clean, fully normal boot instead:

```bash
exec /sbin/init
```

---

## The SELinux Relabel Gotcha

On a system running SELinux in `Enforcing` mode, files touched through either of these early-boot paths — including `/etc/shadow`, rewritten by `passwd` — can end up with the wrong (or missing) security context, because normal boot-time labeling never ran. Flag a relabel before the next real boot, from inside either recovery shell:

```bash
touch /.autorelabel
```

The next normal boot's early init checks for this flag file and performs a full context relabel pass before continuing if it's present. Skip it on an enforcing system and SELinux can start denying access to the very files you just fixed — including, potentially, login itself. This step is easy to forget under pressure and disproportionately costly if you do.

---

## Why This Lab Uses the chroot Mechanic Instead

Module 1 already explained the honest constraint this whole section works within: the lab harness grades your VM by SSHing into it and running a script — it has no way to script an interactive GRUB menu, and it has no way to recover if the VM stops answering SSH. `rd.break` and `init=/bin/bash` both require physically interrupting a boot in progress, which is exactly the kind of interactive, console-level moment this harness cannot automate or grade.

The skill being taught, though, is broader than either specific kernel parameter: **get root-equivalent access to a filesystem via chroot, then run `passwd` (or edit the credential store directly) against it.** That is precisely the same mechanic Module 1 built — mount the target filesystem, get working tools into it, chroot in, make the fix, prove it. So this lab reuses that exact mechanic against a second, disposable disk (the same kind of stand-in described in Module 1), with the fix this time being a locked-out root account instead of a bad fstab line, and the tool this time being `passwd` (or a direct hash edit) instead of `sed`.

Everything upstream of the chroot — recognizing that a healthy-but-locked-out system needs neither rescue media nor a repair, just privileged filesystem access for one operation — is exactly what you'd reach for on the real exam or in a real incident. Only the *specific interactive keystrokes* at a GRUB menu are outside what this environment can drill directly; this lab drills everything else about the technique, faithfully.

---

## The Practical Difference: A Minimal Target Has No Login Stack

One more honest note, specific to this lab's disposable target disk: a real broken system you `chroot` into for a password reset already has its full `/etc` — `/etc/pam.d/`, `/etc/nsswitch.conf`, `/etc/login.defs`, all of it — because it's a real, previously-installed operating system. The stand-in disk this lab builds is deliberately minimal: it carries only what's needed to demonstrate the credential-repair mechanic, not a full authentication stack. Running the interactive `passwd root` command against it may complain about missing PAM configuration it was never given.

The reliable, and equally legitimate, technique in this situation — called out explicitly in the source material this lab is built from — is to generate the password hash directly and splice it into `/etc/shadow` yourself:

```bash
openssl passwd -6 'NewSecurePass123!'
```

```text
$6$abcd1234efgh5678$Xy9k...long-hash-string...
```

`openssl passwd -6` produces a SHA-512-crypt hash in exactly the format `/etc/shadow` expects — the same kind of string `passwd` itself would have written. Open `/etc/shadow` and replace root's hash field (the second colon-delimited field) with this new hash, leaving every other field untouched:

```text
root:$6$abcd1234efgh5678$Xy9k...long-hash-string...:19700:0:99999:7:::
```

This is the same underlying operation `passwd` performs on your behalf on a fully-equipped system — you're just doing the hash generation and file edit explicitly instead of letting an interactive prompt and a full PAM stack do it for you. Both are real, exam-relevant techniques for the same problem: proving you can get a new credential into a target system's `/etc/shadow` via chroot access, without needing that system's own login prompt to cooperate.

---

## Self-Check and Verification

1. **Choosing the technique:** A colleague reaches for a full external rescue-media boot to reset a forgotten root password on a system that otherwise boots perfectly fine. Is that the right call? *(Answer: No — the system is healthy, so a one-boot GRUB kernel-parameter edit (`rd.break` or `init=/bin/bash`) is faster and sufficient; rescue media is reserved for systems that genuinely cannot boot on their own.)*
2. **Where you land:** What's different about *where in the boot sequence* `rd.break` drops you compared to `init=/bin/bash`, and what extra step does that difference require? *(Answer: `rd.break` lands you in the initramfs before the real root is mounted as `/` — it's only at `/sysroot`, requiring an explicit `chroot /sysroot`. `init=/bin/bash` lands you after the real root is already mounted as `/`, with no chroot step needed.)*
3. **Persistence:** Is the kernel command-line edit made at the GRUB menu saved anywhere, and will it reappear on the next normal reboot? *(Answer: No — it's a one-time, in-memory edit for that single boot only; a normal reboot afterward reverts to the standard, unmodified boot entry.)*
