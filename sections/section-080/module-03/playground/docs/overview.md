# Overview: Partition Table Backup and Restore Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-partition-table-bench`.
- A second, 2 GB disk with the serial `lab083-vdc`. Find it at `/dev/disk/by-id/virtio-lab083-vdc`.
- On that disk, a GPT partition table with two ext4 partitions, each holding a marker file.
- `sgdisk`, `blkid` and `lsblk`.
- Your own machine stays healthy and reachable; the broken system lives on the spare disk.

## Things to try

- Print the table with `sudo sgdisk -p /dev/disk/by-id/virtio-lab083-vdc`.
- Save it with `sudo sgdisk --backup=/root/disk.gpt /dev/disk/by-id/virtio-lab083-vdc`, and check the file exists.
- Wipe the table with `sudo sgdisk --zap-all`, then restore it with `sudo sgdisk --load-backup=/root/disk.gpt`.
- Mount a partition and check that the marker file survived.

## When you are done

```sh
astrona destroy partition-table-bench
```

`astrona destroy` takes the playground's name, `partition-table-bench`, not the folder path. The running machine is called `astro-partition-table-bench`.
