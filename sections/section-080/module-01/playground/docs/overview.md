# Overview: Root-Filesystem Repair via chroot Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-chroot-rescue-bench`.
- A second, 2 GB disk with the serial `lab081-data001`. Find it at `/dev/disk/by-id/virtio-lab081-data001`. Its device letter is not fixed, so never type a raw `/dev/vdX` name.
- On that disk, a small root partition that holds a stand-in `data-001` system with its own `/etc/fstab`, and a data partition. The `fstab` line for the data partition has a mistyped UUID.
- `chroot`, `blkid`, `lsblk` and `mount`, the tools you need to step into the stand-in system and fix it.
- Your own machine stays healthy and reachable; the broken system lives on the spare disk.

## Things to try

- Run `lsblk` and `blkid` and find the spare disk by its serial.
- Mount the stand-in root partition, bind-mount `/dev`, `/proc` and `/sys` into it, and share this machine's tools with it, as the module shows.
- Step in with `chroot`, compare the `UUID=` in `/etc/fstab` with `blkid`, and correct the line.
- Prove the fix with `mount -a` inside the `chroot`, then unmount everything.

## When you are done

```sh
astrona destroy chroot-rescue-bench
```

`astrona destroy` takes the playground's name, `chroot-rescue-bench`, not the folder path. The running machine is called `astro-chroot-rescue-bench`.
