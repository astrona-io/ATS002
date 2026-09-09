# section-080 / module-01 / lab-02: chroot repair — wrong fstab filesystem type

QEMU VM for the LFCS course. Companion to lab-01's mistyped-UUID fault. Here
the `/data` fstab entry's device identifier is correct, but the type field
says `ext4` where the partition is actually `xfs` — so `mount -a` fails with
`wrong fs type, bad superblock`. Same chroot mechanic; the student must
cross-check **every** field of the entry against `blkid`, not just the
device, and fix field 3.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-02
```
