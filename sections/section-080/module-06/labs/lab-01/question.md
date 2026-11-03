# Question

Solve this question on: `terminal`

The initramfs image of the kernel this machine is running has been deleted from `/boot`. The machine still runs, but it would not boot again. Do **not** reboot it.

1. Find out which kernel release is running, and confirm that its image `/boot/initrd.img-<release>` is missing.
2. Create a new initramfs image for the running kernel with the Ubuntu tool for it.
3. Check the new image: it exists in `/boot`, it is not empty, and `lsinitramfs` can list its contents.
4. Confirm that the `/boot/initrd.img` link points to an existing file.

The grader checks that:

- `/boot/initrd.img-<running kernel>` exists, is not empty, and was created after the lab started
- `lsinitramfs` can read it and it contains the initramfs boot scripts
- `/boot/initrd.img` resolves to an existing file
