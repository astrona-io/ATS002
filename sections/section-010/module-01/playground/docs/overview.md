# Overview: sysctl live-kernel playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh` once, and waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy`, and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine, your training ship. Open a terminal on it with `astrona ssh astro-sysctl-live-kernel`.
- Its own real kernel, the ship's reactor core. `sysctl -w` really changes live kernel values here.
- `procps` (`sysctl`), `coreutils` (`uname`) and `systemd` (`timedatectl`) are already installed. Nothing has been changed for you.
- `lsblk` shows `vda` (about 15 GiB, the system disk) and `vdb` (about 366 KiB, the cloud-init disk with start-up settings). There are no extra disks.

## Things to try

- Compare `uname -r`, `uname -v` and `uname -a`, and see which field is which.
- Run `sysctl net.ipv4.ip_forward`, then `cat /proc/sys/net/ipv4/ip_forward`: the same value through two paths.
- Run `sudo sysctl -w net.ipv4.ip_forward=1`, confirm it with `sysctl -n net.ipv4.ip_forward`, and notice that no file on disk changed.
- Make the change survive a reboot. Save the line `net.ipv4.ip_forward = 1` as `/etc/sysctl.d/99-fwd.conf`, then apply it with `sudo sysctl --system`. The value is now live *and* written down.
- Run `timedatectl show --property=Timezone --value` to get the timezone as one clean field.

## When you are done

```sh
astrona destroy sysctl-live-kernel
```

`astrona destroy` takes the playground's name, `sysctl-live-kernel`. The running machine itself is called `astro-sysctl-live-kernel`, which is the name `astrona ssh` uses.
