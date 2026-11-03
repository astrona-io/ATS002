# Initramfs Rebuild

Astronaut, the kernel is the ship's engine, but an engine alone cannot find the fuel. Before the real root filesystem is available, the kernel needs drivers for the disk, the filesystem and sometimes encryption or RAID. Those drivers travel in a small boot crate called the initramfs. Without it, a perfectly good kernel stops at an emergency prompt.

In this module you learn what is inside that crate, how to check it, and how to rebuild it when it is missing or stale.

## Learning objectives

After this module you can:

- Explain what the initramfs is for and when it is used.
- Name the files in `/boot` that belong to one kernel.
- List the contents of an image with `lsinitramfs`.
- Create, update and remove images with `update-initramfs -c`, `-u` and `-d`.
- Rebuild an image from a rescue chroot, and name the Red Hat family tool, `dracut`.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **What the kernel is**, and that `uname -r` prints its release.
- **How to use a chroot** from a rescue shell.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with a healthy `/boot`.

- The running kernel and its initramfs image in `/boot`. A listing of it is saved in `/root/boot-listing.original.txt`.
- `update-initramfs`, `lsinitramfs` and `uname`.
- Your own machine stays healthy. Do not reboot it after you delete an image.

Start the playground, then open a terminal on it with `astrona ssh astro-initramfs-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [What The Initramfs Is](./course-01-what-the-initramfs-is.md): the boot crate, what it holds and the files that belong to one kernel.
2. [Inspect And Rebuild The Initramfs](./course-02-inspect-and-rebuild.md): `lsinitramfs`, `update-initramfs -c`, `-u` and `-d`, rebuilding from a chroot, and `dracut` on Red Hat family systems.
   - Mission: Initramfs Rebuild Lab
3. [Summary](./course-03-wrap-up.md)

## Why this matters

A kernel update that ran out of disk space, a deleted file in `/boot` or a new storage driver can all leave you with a machine that works until the next reboot. Knowing the one command that rebuilds the image turns a recovery that ends in a reinstall into a two-minute job.
