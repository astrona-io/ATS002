# lab-083: Partition Table Backup & Recovery

QEMU VM for the LFCS course — backing up a GPT partition table with `sgdisk`, verifying it, simulating a disaster, and restoring, on a real secondary disk.

This scenario needs no safety adaptation: it operates entirely on a non-root secondary disk, and the VM stays fully SSH-reachable throughout.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-083
```
