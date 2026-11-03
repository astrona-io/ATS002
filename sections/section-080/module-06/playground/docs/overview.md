# Overview: Initramfs Rebuild Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-initramfs-bench`.
- A healthy `/boot` with the kernel and its initramfs image. A listing of it is saved in `/root/boot-listing.original.txt`.
- `update-initramfs`, `lsinitramfs` and `uname`.
- Your own machine stays healthy and reachable. Do not reboot it after you delete an image, because the playground cannot be paused and a machine that cannot boot is gone for good.

## Things to try

- Name the running kernel with `uname -r`, and list `/boot`.
- List what is inside the image: `sudo lsinitramfs /boot/initrd.img-$(uname -r) | head -30`.
- Rebuild it in place: `sudo update-initramfs -u -k $(uname -r)`, and watch the file's time change in `ls -l /boot`.
- Delete the image, then create it again with `sudo update-initramfs -c -k $(uname -r)`.
- Compare `/boot/initrd.img` and `/boot/initrd.img-$(uname -r)` with `ls -l`.

## When you are done

```sh
astrona destroy initramfs-bench
```

`astrona destroy` takes the playground's name, `initramfs-bench`, not the folder path. The running machine is called `astro-initramfs-bench`.
