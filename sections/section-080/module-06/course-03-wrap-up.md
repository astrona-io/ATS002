# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about the initramfs, the boot crate that lets the kernel find the real root filesystem, and how to rebuild it.

**From [What The Initramfs Is](./course-01-what-the-initramfs-is.md):**

- The initramfs is a small archive loaded into memory with the kernel. It carries the drivers and scripts needed to find and mount the root filesystem.
- Each kernel has `vmlinuz-<release>` and `initrd.img-<release>` in `/boot`. The `initrd.img` link points at the newest.
- `lsinitramfs` lists an image's contents. It needs root.

**From [Inspect And Rebuild The Initramfs](./course-02-inspect-and-rebuild.md):**

- `update-initramfs -c` creates, `-u` updates and `-d` deletes. `-k` names the release.
- In a rescue chroot, use the installed kernel's release, not `uname -r`, and bind-mount `/dev`, `/proc` and `/sys`.
- Red Hat family systems use `dracut` and `lsinitrd`.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Initramfs Rebuild Lab](./labs/lab-01/README.md) | Inspect And Rebuild The Initramfs | Rebuilt a missing initramfs image for the running kernel and checked it |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What is the initramfs for?</summary>

It carries the drivers and scripts the kernel needs to find and mount the real root filesystem.
</details>

<details>
<summary>2. The image of the running kernel is missing. Which option do you use: <code>-u</code> or <code>-c</code>?</summary>

`-c`. `-u` only updates an image that already exists.
</details>

<details>
<summary>3. Why not use <code>$(uname -r)</code> inside a rescue chroot?</summary>

Inside the chroot, `uname -r` reports the rescue kernel that is running, not the installed kernel you want to repair. Read the release from `/boot`.
</details>

<details>
<summary>4. Which tool builds the image on Rocky Linux?</summary>

`dracut`.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy initramfs-bench
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-087
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
