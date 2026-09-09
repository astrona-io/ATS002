# Solution Walkthrough

This lab practices the chroot half of the real GRUB-interrupt password-reset technique, against a disposable stand-in disk instead of your primary VM's own boot process.

---

## Step 1: Identify the Stand-In Disk

```bash
lsblk -f
```

```text
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
vda
└─vda1 ext4                   1a2b3c4d-...                         /
vdb    ext4     DATA001ROOT   9f8e7d6c-1111-2222-3333-444455556666
```

Note your actual device letter — it can vary run to run.

---

## Step 2: Mount It

```bash
sudo mkdir -p /mnt/repair
sudo mount /dev/vdb /mnt/repair
```

---

## Step 3: Bind-Mount Tools In (Read-Only)

```bash
sudo mount --bind /usr /mnt/repair/usr
sudo mount --bind /bin /mnt/repair/bin
sudo mount --bind /sbin /mnt/repair/sbin
sudo mount --bind /lib /mnt/repair/lib
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
```

---

## Step 4: Bind-Mount /dev, /proc, /sys

```bash
sudo mount --bind /dev /mnt/repair/dev
sudo mount --bind /proc /mnt/repair/proc
sudo mount --bind /sys /mnt/repair/sys
```

---

## Step 5: chroot In

```bash
sudo chroot /mnt/repair /bin/bash
```

Confirm you're really inside the stand-in system:

```bash
cat /etc/hostname
# data-001
```

---

## Step 6: Reset the Password Hash

Check the current state:

```bash
cat /etc/shadow
```

```text
root:!:19700:0:99999:7:::
```

The `!` in the second field means the account is locked — this lab's stand-in for "the password is lost." This minimal disk doesn't carry a full PAM/login stack, so `passwd root` may complain about missing configuration it was never given. The reliable technique here — just as legitimate as the interactive prompt — is to generate the hash directly and splice it in:

```bash
openssl passwd -6 'NewSecurePass123!'
```

```text
$6$abcd1234efgh5678$Xy9k...long-hash-string...
```

`openssl passwd -6` produces a SHA-512-crypt hash in exactly the format `/etc/shadow` expects. Edit `/etc/shadow` and replace the `!` with this hash, leaving every other field untouched:

```bash
sed -i 's|^root:![^:]*|root:$6$abcd1234efgh5678$Xy9k...long-hash-string...|' /etc/shadow
```

(Editing with `vi /etc/shadow` directly and pasting the hash into the second field works just as well — either way, confirm the result afterward.)

```bash
cat /etc/shadow
```

```text
root:$6$abcd1234efgh5678$Xy9k...long-hash-string...:19700:0:99999:7:::
```

---

## Step 7: Exit and Unmount Cleanly

```bash
exit
```

```bash
sudo umount -R /mnt/repair
```

---

## Verification

```bash
sudo mkdir -p /mnt/check
sudo mount -o ro /dev/vdb /mnt/check
sudo grep '^root:' /mnt/check/etc/shadow
sudo umount /mnt/check
```

The second field should now be a real hash (starting with `$6$` or similar), not `!`. Once verified, run the local validation suite to pass the lab.

---

## A Note on the Real, Physical Technique

On a real, healthy-but-locked-out server, you would never need any of this chroot machinery — you'd interrupt GRUB for one boot, append `rd.break` (drop into the initramfs, `mount -o remount,rw /sysroot`, `chroot /sysroot`, `passwd root`) or `init=/bin/bash` (land directly on the real root, `mount -o remount,rw /`, `passwd root`), and reset the password interactively in seconds, with no external media and no separate hash-splicing step. This lab teaches the chroot-and-credential-file mechanic that technique shares with Module 1's fstab repair — practice both approaches conceptually, since the real exam may test either.
