# Overview: Filesystem Check and Repair Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-fsck-repair-bench`.
- A second, 1 GB disk with the serial `lab086-data001`. Find it at `/dev/disk/by-id/virtio-lab086-data001`.
- On that disk, one GPT partition with a healthy ext4 filesystem (label `CARGO`, 4096-byte blocks) holding `marker.txt` and `logs/flight.log`.
- `e2fsck`, `dumpe2fs`, `mke2fs`, `blkid` and `lsblk`.
- Your own machine stays healthy and reachable; the damaged system lives on the spare disk.

## Things to try

- Set a variable for the disk: `DISK=$(readlink -f /dev/disk/by-id/virtio-lab086-data001)`.
- Read the superblock: `sudo dumpe2fs -h ${DISK}1`.
- Run a read-only check: `sudo fsck.ext4 -n -f ${DISK}1`.
- Break it on purpose, with the partition unmounted: `sudo dd if=/dev/zero of=${DISK}1 bs=1024 seek=1 count=1 conv=notrunc`. Then try to mount it and repair it with `sudo e2fsck -b 32768 -y ${DISK}1`.
- List where the backup superblocks live with the dry run `sudo mke2fs -n -b 4096 ${DISK}1`. Never leave out `-n`: without it the command creates a new empty filesystem.

## When you are done

```sh
astrona destroy fsck-repair-bench
```

`astrona destroy` takes the playground's name, `fsck-repair-bench`, not the folder path. The running machine is called `astro-fsck-repair-bench`.
