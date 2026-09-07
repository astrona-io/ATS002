# Overview — sysctl live-kernel playground

A **playground**, not a lab: it boots, runs `bootstrap/prepare.sh`, and waits. No task, no `astrona submit`, no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- One Ubuntu 24.04 qemu VM, reached with `astrona ssh astro-sysctl-live-kernel`.
- Its own real kernel — `sysctl -w` genuinely changes live kernel state here.
- `procps` (`sysctl`), `coreutils` (`uname`), and `systemd` (`timedatectl`) already installed. Nothing was pre-configured.
- `lsblk` shows `vda` (~15 GiB OS disk) and `vdb` (~366 KiB cloud-init disk). No extra disks.

## Things to try

- `uname -r` vs `uname -v` vs `uname -a` — see which field is which.
- `sysctl net.ipv4.ip_forward` then `cat /proc/sys/net/ipv4/ip_forward` — same value, two paths.
- `sudo sysctl -w net.ipv4.ip_forward=1`, confirm with `sysctl -n`, then note nothing on disk changed.
- `echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-fwd.conf && sudo sysctl --system` — immediate *and* reboot-proof.
- `timedatectl show --property=Timezone --value`.

## When you're done

```sh
astrona destroy sysctl-live-kernel
```

(`astrona destroy` takes the environment name, `sysctl-live-kernel`; the running machine is `astro-sysctl-live-kernel`.)
