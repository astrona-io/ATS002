# Part 2 — The chroot equivalent, and editing `/etc/shadow` directly

> Prerequisite: [Part 1 — Two doors: `rd.break` and `init=/bin/bash`](./course-01-two-doors-rd-break-and-init.md). Next: [Section 080 quiz](../quiz.md).

The interactive GRUB keystrokes from Part 1 cannot be scripted, so this lab reaches the same end state via the chroot mechanic from Module 1. This part is why that is equivalent, and the direct-hash technique for when the target has no working `passwd`.

## The skill is broader than the keystrokes

`rd.break` and `init=/bin/bash` are two ways to reach one place: **root-equivalent access to a filesystem, then run `passwd` (or edit the credential store) against it.** That is exactly the Module 1 mechanic — mount the target, get tools in, `chroot`, make the fix, prove it. So the recovery here is:

```bash
# shell: repair host, root — target root already mounted at /mnt/repair with /dev,/proc,/sys bound (Module 1, Part 2)
sudo chroot /mnt/repair /bin/bash
passwd root
```

Everything upstream of the chroot — recognising that a healthy-but-locked-out system needs neither rescue media nor a repair, just privileged filesystem access for one operation — is the real exam skill. Only the specific GRUB-menu keystrokes are outside what an SSH-only harness can drill.

## When the target has no working `passwd`

A real previously-installed system has a full `/etc` — `pam.d/`, `nsswitch.conf`, `login.defs`. A minimal stand-in disk may carry only enough to demonstrate the mechanic, and interactive `passwd root` can then fail complaining about missing PAM config it never had.

The reliable alternative — and an equally legitimate exam technique — is to generate the hash yourself and splice it into `/etc/shadow`:

```bash
openssl passwd -6 'NewSecurePass123!'
```

```text
$6$abcd1234efgh5678$Xy9k...long-hash...
```

`openssl passwd -6` produces a **SHA-512-crypt** hash in exactly the format `/etc/shadow` expects — the same kind of string `passwd` would write. (`-1` = MD5, `-5` = SHA-256; `-6` is the current default on RHEL/Debian.) `mkpasswd -m sha-512` (from `whois`) does the same.

Then edit `/etc/shadow` — replace **only the second colon-delimited field** (the hash) for `root`, leaving every other field untouched:

```text
root:$6$abcd1234efgh5678$Xy9k...long-hash...:19700:0:99999:7:::
```

```
   root : <hash> : lastchg : min : max : warn : inactive : expire :
    │      │        │
    │      │        └─ field 3+ — do not touch
    │      └─ field 2 — the ONLY field you replace
    └─ field 1 — username
```

This is the same underlying operation `passwd` performs — you are just doing the hash generation and file edit explicitly. Both prove the same competency: getting a new credential into a target's `/etc/shadow` via chroot access, without the target's own login prompt cooperating.

Back out and unmount exactly as Module 1, Part 3 describes.

> [!WARNING]
> - **Replacing a field other than the second in `/etc/shadow`** → you can lock or expire the account. Only the hash field changes.
> - **Pasting a non-crypt string as the hash** → login fails; it must be a real `$6$...` (or `$5$`, `$1$`) crypt hash. Use `openssl passwd -6` or `mkpasswd`.
> - **`passwd` failing on a minimal target and giving up** → switch to the `openssl passwd -6` + direct edit; it needs no PAM stack.
> - **Forgetting the SELinux relabel** (Part 1) when the target is enforcing → `touch /mnt/repair/.autorelabel` before unmounting.

> *The exam skill is "chroot to the target, then `passwd root`"; when the target has no working PAM, generate a `$6$` hash with `openssl passwd -6` and replace only the second field of root's `/etc/shadow` line — both put a new credential in place without the target's login prompt.*

## Reference

- `man 1 passwd` / `man 5 shadow` — the `/etc/shadow` field layout; which field is the hash.
- `man 1ssl passwd` (`openssl passwd`) — `-6` / `-5` / `-1`, `-salt`; the crypt formats.
- `man 1 mkpasswd` (from `whois`) — `-m sha-512`, the alternative hash generator.
