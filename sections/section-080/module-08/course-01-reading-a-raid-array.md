# Reading A RAID Array

Astronaut, before you replace anything you must read the array. This part explains what a mirror does, where Linux reports its health, and how a degraded array looks in the two places that show it.

## What a mirror does

RAID 1 is a mirror: every write goes to both member disks, so each disk holds a full copy. If one disk dies, the array keeps running on the other one. In the ship picture, it is the same cargo kept in two bays.

The kernel's `md` driver does the work, and `mdadm` is the tool you use to create, inspect and repair arrays. The array appears as a normal block device, such as `/dev/md127`, with a friendly link at `/dev/md/cargo`. You put a filesystem on the array, never on a member disk.

## See it in your playground

The quickest health check is the kernel's own summary file:

<!-- astrona:playground:renew -->

```bash
# shell: playground, root rights through sudo
cat /proc/mdstat
```

Each array has a line with its level (`raid1`) and its members. The line below it ends with a pair of brackets, `[UU]`. Each `U` is a member that is up. A missing member shows as `_`, so a degraded two-disk mirror reads `[U_]` or `[_U]`.

The full report comes from `mdadm --detail`:

```bash
sudo mdadm --detail /dev/md/cargo
```

Look for four lines. `State` says `clean` (healthy) or `clean, degraded` (running on fewer disks than it should). `Active Devices` and `Working Devices` count the members that work. `Failed Devices` counts the dead ones. At the bottom, a table lists each member with its state, such as `active sync`, `faulty` or `spare`.

## Which disk is in the array

`mdadm --examine` reads the RAID label (the md superblock) that mdadm writes on every member. It tells you which array a disk belongs to, even when the array is stopped:

```bash
sudo mdadm --examine "$(readlink -f /dev/disk/by-id/virtio-lab089-raid-a)"
```

The label has the array's UUID, its name and the member's role. The blank spare, disk `c`, has no label, so `--examine` reports that no md superblock was found.

## Practise a failure

You can make a member fail on purpose. Mark disk `b` as faulty, then read the array again:

```bash
DISK_B=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-b)
sudo mdadm /dev/md/cargo --fail "$DISK_B"
cat /proc/mdstat
sudo mdadm --detail /dev/md/cargo
```

The array stays up and the files stay readable, because disk `a` still holds a full copy. `/proc/mdstat` now shows `[U_]` or `[_U]`, and `--detail` shows the state `degraded` and disk `b` as `faulty`.

## Common pitfalls

- Reading `/proc/mdstat` and trusting the array name. Count the `U` characters: one `U` in a mirror means no redundancy.
- Putting a filesystem on a member disk instead of on the array.
- Assuming a degraded array needs no attention because the files are still there.
