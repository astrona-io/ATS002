# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished both parts and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about getting back into a healthy machine whose root password is lost, and writing a new password into `/etc/shadow`.

**From [Two Doors: rd.break And init=/bin/bash](./course-01-two-doors-rd-break-and-init.md):**

- At the GRUB menu, press `e`, add one parameter to the end of the `linux` line and boot with `Ctrl-X` or `F10`. Nothing is saved.
- `rd.break` (dracut, RHEL family) stops inside the initramfs with the real root read-only at `/sysroot`: `mount -o remount,rw /sysroot`, `chroot /sysroot`, `passwd root`, then `exit` twice.
- `init=/bin/bash` runs bash as PID 1 on the real root: `mount -o remount,rw /`, `passwd root`, then `exec /sbin/init`, never `reboot`.
- On a system that enforces SELinux, `touch /.autorelabel` before leaving.

**From [The chroot Equivalent And Editing /etc/shadow](./course-02-chroot-equivalent-and-shadow-edit.md):**

- A chroot reaches the same place as the two doors: root access to the target's files.
- When `passwd` cannot run, make a hash with `openssl passwd -6` (or `mkpasswd -m sha-512`).
- Replace only the second field of root's line in `/etc/shadow`, and leave every other field alone.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Password Reset & Single-User Recovery Lab](./labs/lab-01/README.md) | The chroot Equivalent And Editing /etc/shadow | Unlocked a stand-in system's root account by writing a real hash into its `/etc/shadow` through a chroot |

If you skipped it, go back to it now. The exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. The server boots fine, but nobody knows the root password and no other account has <code>sudo</code>. Do you need rescue media?</summary>

No. The system boots on its own, so a one-boot GRUB edit (`init=/bin/bash`, or `rd.break` on RHEL-family systems) is faster and needs no extra media.
</details>

<details>
<summary>2. After <code>rd.break</code>, you run <code>passwd root</code> straight away. Why does the new password not work after the boot?</summary>

You changed the initramfs's temporary `/etc/shadow`. You must run `mount -o remount,rw /sysroot` and `chroot /sysroot` first, so `passwd` changes the real one.
</details>

<details>
<summary>3. How do you leave the shell after <code>init=/bin/bash</code>, and why not <code>reboot</code>?</summary>

With `exec /sbin/init`. `reboot` asks systemd to restart the machine, and systemd is not running, so nothing handles the request.
</details>

<details>
<summary>4. What does <code>touch /.autorelabel</code> do, and when do you need it?</summary>

It asks for a full SELinux relabel early in the next boot. You need it on a system that enforces SELinux, because files changed through the two doors can have wrong labels.
</details>

<details>
<summary>5. <code>passwd root</code> fails inside a chroot with errors about missing PAM files. What do you do?</summary>

Make a hash with `openssl passwd -6 'password'` and put it into the second field of root's line in `/etc/shadow` with an editor or `sed`.
</details>

<details>
<summary>6. Root's line is <code>root:!:19700:0:99999:7:::</code>. What does the <code>!</code> mean, and which part do you replace?</summary>

The `!` means the account is locked. Replace only that second field with the new hash, and keep `19700:0:99999:7:::` as it is.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-082
```

Then run `astrona list` again to check that everything is gone.
