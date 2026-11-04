# Inspect And Rebuild The Initramfs

Astronaut, now that you know what the image is, here is how to make a new one. On Ubuntu one tool, `update-initramfs`, does it all.

## The three modes of `update-initramfs`

<!-- astrona:playground:renew -->

```bash
# shell: repair host, root
sudo update-initramfs -u -k "$(uname -r)"    # update an existing image
sudo update-initramfs -c -k "$(uname -r)"    # create a new image
sudo update-initramfs -d -k "$(uname -r)"    # delete an image
```

- `-u` updates an image that already exists. It fails if there is none.
- `-c` creates a new image. Use it when the image is missing.
- `-d` removes an image. Do not run it on the running kernel on a real machine.
- `-k` names the kernel release. `-k all` handles every installed kernel.
- `-v` prints what is added.

Run `-u` first on your playground and watch the file's time in `ls -l /boot` change. Then use `-d` and `-c` together to see the image disappear and return. Do not reboot between them.

## Check the result

```bash
ls -l /boot/initrd.img-"$(uname -r)"
sudo lsinitramfs /boot/initrd.img-"$(uname -r)" | head
ls -l /boot/initrd.img
```

The image should have a plausible size (tens of megabytes), `lsinitramfs` should list files, and the `/boot/initrd.img` link should point at an image that exists.

## Rebuilding from a rescue chroot

When the machine does not boot, you work from a rescue shell, as in module 01 of this section. Mount the root filesystem and `/boot`, bind the virtual filesystems, chroot in, and rebuild for the **installed** kernel, whose release you read from `/boot`:

```bash
# shell: rescue shell, root
for d in dev proc sys; do mount --bind /$d /mnt/$d; done
chroot /mnt update-initramfs -c -k 6.8.0-XX-generic
```

Replace `6.8.0-XX-generic` with the release you see in `ls /mnt/boot`. Inside a chroot, `uname -r` shows the rescue kernel, not the installed one, so never use `$(uname -r)` there.

## Red Hat family and SUSE

Fedora, Rocky and RHEL build the image, called **initramfs** too, with `dracut`, not `update-initramfs`. The command `dracut -f /boot/initramfs-<release>.img <release>` rebuilds it, and `lsinitrd` lists its contents. This module's mission uses Ubuntu.

## Common pitfalls

- Using `-u` when the image is missing: use `-c`.
- Using `$(uname -r)` inside a rescue chroot.
- Forgetting the bind mounts in a chroot, so the tool cannot see `/proc` and `/dev`.
- Running low on space in `/boot`: the build then fails or leaves a partial image. Check `df -h /boot`.

## Your mission: Initramfs Rebuild Lab

You can now inspect an image, create and update one, and check the result. The mission removes the running kernel's image from `/boot` and asks you to bring it back, without rebooting.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy initramfs-bench
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-06/labs/lab-01
astrona ssh ats-002-lab-087
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-06/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-087
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-06/playground
```
