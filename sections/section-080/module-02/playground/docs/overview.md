# Overview: Password Reset With a Rescue Shell Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-password-reset-bench`.
- A second, 1 GB disk with the serial `lab082-data001`. Find it at `/dev/disk/by-id/virtio-lab082-data001`.
- On that disk, a stand-in root filesystem with its own `/etc/shadow`, where the root password field is `!`, which means the account is locked.
- `chroot`, `mount` and `passwd`, the tools you need to set a new password inside the stand-in system.
- Your own machine stays healthy and reachable; the broken system lives on the spare disk.

## Things to try

- Mount the stand-in root partition and read its `/etc/shadow` with `sudo grep '^root:' <mount point>/etc/shadow`.
- Bind-mount `/dev`, `/proc` and `/sys`, step in with `chroot`, and set a new root password with `passwd root`.
- Read the `root:` line of `/etc/shadow` again and see that the `!` is gone.
- Unmount everything when you finish.

## When you are done

```sh
astrona destroy password-reset-bench
```

`astrona destroy` takes the playground's name, `password-reset-bench`, not the folder path. The running machine is called `astro-password-reset-bench`.
