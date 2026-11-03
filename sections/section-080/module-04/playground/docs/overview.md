# Overview: GRUB Recovery Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-grub-repair-bench`.
- A healthy Ubuntu 24.04 machine with a working `/boot/grub/grub.cfg`. The setup script saves a copy at `/root/grub.cfg.original`.
- `update-grub`, `grub-mkconfig`, `grub-install` and `grub-probe`.
- No broken boot menu: a ship that really fails to boot cannot be reached over SSH. You practise the repair commands on a healthy ship, and the `grub>` prompt steps stay a worked walkthrough.

## Things to try

- Read the menu file with `sudo less /boot/grub/grub.cfg`.
- Generate a menu into a test file with `sudo grub-mkconfig -o /root/grub.cfg.test`, then compare it with `diff`.
- Look at what `grub-probe` reports for `/` and `/boot`.
- Read `/etc/default/grub` and see which settings `update-grub` turns into menu lines.

## When you are done

```sh
astrona destroy grub-repair-bench
```

`astrona destroy` takes the playground's name, `grub-repair-bench`, not the folder path. The running machine is called `astro-grub-repair-bench`.
