# Solution Walkthrough

This walkthrough practises the chroot half of the real password reset, against a disposable stand-in disk instead of your own machine's boot. Your machine is the rescue ship; the stand-in disk is the locked-out one.

---

## Step 1: Identify the stand-in disk

```bash
lsblk -f
```

```text
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
vda
└─vda1 ext4                   1a2b3c4d-...                         /
vdb    ext4     DATA001ROOT   9f8e7d6c-1111-2222-3333-444455556666
```

This output is a shortened example with made-up UUIDs. On Ubuntu 24.04, `lsblk -f` shows a few more columns and the main disk has more partitions.

The stand-in disk has no partitions: the filesystem labelled `DATA001ROOT` covers the whole disk. Note your own device letter, because it can change between runs. The stable path `/dev/disk/by-id/virtio-lab082-data001` always points at this disk.

---

## Step 2: Mount it

```bash
sudo mkdir -p /mnt/repair
sudo mount /dev/vdb /mnt/repair
```

---

## Step 3: Bind-mount the tools in

```bash
sudo mount --bind /usr /mnt/repair/usr
sudo mount --bind /bin /mnt/repair/bin
sudo mount --bind /sbin /mnt/repair/sbin
sudo mount --bind /lib /mnt/repair/lib
[ -e /lib64 ] && sudo mount --bind /lib64 /mnt/repair/lib64
```

The stand-in disk has no programs of its own. These bind mounts lend it this machine's `bash`, `openssl`, `sed` and libraries. Nothing is copied.

---

## Step 4: Bind-mount `/dev`, `/proc` and `/sys`

```bash
sudo mount --bind /dev /mnt/repair/dev
sudo mount --bind /proc /mnt/repair/proc
sudo mount --bind /sys /mnt/repair/sys
```

---

## Step 5: chroot in

```bash
sudo chroot /mnt/repair /bin/bash
```

Confirm you are really inside the stand-in system:

```bash
cat /etc/hostname
# data-001
```

---

## Step 6: Reset the password hash

Look at the current state:

```bash
cat /etc/shadow
```

```text
root:!:19700:0:99999:7:::
```

The `!` in the second field means the account is locked. In this lab it stands in for "the password is lost". This small disk has no full PAM setup, so `passwd root` may fail with errors about missing configuration. The reliable way, and an equally valid one, is to make the hash yourself and put it in:

```bash
openssl passwd -6 'NewSecurePass123!'
```

```text
$6$abcd1234efgh5678$Xy9k...long-hash-string...
```

This output is shortened. Your real hash is much longer and different every time, because the salt is random.

`openssl passwd -6` makes a SHA-512-crypt hash in exactly the format `/etc/shadow` expects. Replace the `!` with this hash and leave every other field as it is:

```bash
sed -i 's|^root:![^:]*|root:$6$abcd1234efgh5678$Xy9k...long-hash-string...|' /etc/shadow
```

Paste your own full hash into this command in place of the example. The single quotes stop the shell from treating the `$` signs in the hash as variables. The `|` characters are the `sed` separators, because a hash can contain `/`.

Opening `/etc/shadow` in `vi` or `nano` and pasting the hash into the second field works just as well. Either way, check the result:

```bash
cat /etc/shadow
```

```text
root:$6$abcd1234efgh5678$Xy9k...long-hash-string...:19700:0:99999:7:::
```

---

## Step 7: Exit and unmount cleanly

```bash
exit
```

```bash
sudo umount -R /mnt/repair
```

---

## Verification

Check the result from outside any chroot, the same way the grader does:

```bash
sudo mkdir -p /mnt/check
sudo mount -o ro /dev/vdb /mnt/check
sudo grep '^root:' /mnt/check/etc/shadow
sudo umount /mnt/check
```

The second field should now be a real hash starting with `$6$`, not `!`. When it is, send the lab for grading from your own computer:

```bash
astrona submit -c sections/section-080/module-02/labs/lab-01
```

---

## The real, console technique

On a real server that boots fine but is locked out, you would not need any of this chroot setup. You would interrupt GRUB for one boot and add a parameter to the `linux` line:

- `rd.break` (RHEL-family systems with dracut): you land in the initramfs. Run `mount -o remount,rw /sysroot`, `chroot /sysroot` and `passwd root`.
- `init=/bin/bash`: you land directly on the real root. Run `mount -o remount,rw /` and `passwd root`, then `exec /sbin/init`.

No rescue media and no separate hash step are needed there. This lab drills the part both techniques share with any chroot repair: getting root access to the target's files and writing a new password into its `/etc/shadow`. Know both routes, because the exam may ask for either.
