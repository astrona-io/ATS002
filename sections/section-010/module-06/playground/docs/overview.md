# Overview: systemd service-debugging playground

This is a **playground**, not a lab. It starts, runs `bootstrap/prepare.sh` once and then waits for you. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- One Ubuntu 24.04 training ship (a `qemu` virtual machine). Open a terminal on it with `astrona ssh astro-systemd-service-debugging`.
- `apache2`, installed but **`failed`**. A small helper unit, **`port80-hog.service`**, runs a `socat` listener that holds TCP port 80. So `systemctl start apache2` fails with `(98)Address already in use` and `AH00072`. That gives you a real failed unit with a real trail in the journal.
- The tools `socat` and `iproute2` (which provides `ss`).
- No extra disks. `lsblk` shows the 15 GB system disk and a very small disk used once at startup to set up the machine (cloud-init).

## Things to try

- `systemctl status apache2`: read `Active: failed (Result: exit-code)` and the short log tail under it.
- `systemctl is-active apache2`, `systemctl is-enabled apache2` and `systemctl --failed`.
- `systemctl cat apache2` and `systemctl show apache2 -p FragmentPath -p DropInPaths`.
- `journalctl -xeu apache2`: the chain of errors. The first real error is the failure to bind port 80.
- `sudo ss -ltnp 'sport = :80'`: see `socat`, started by `port80-hog`, holding the port.
- Fix it: run `sudo systemctl stop port80-hog`, then `sudo systemctl start apache2`. Check with `systemctl is-active apache2`, then run `sudo systemctl enable --now apache2` so it also starts at boot.

## When you are done

Remove the playground. It always starts clean, so nothing you change carries over:

```sh
astrona destroy systemd-service-debugging
```
