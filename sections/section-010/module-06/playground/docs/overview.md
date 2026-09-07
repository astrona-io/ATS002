# Overview — systemd service-debugging playground

A **playground**, not a lab: boots, runs `bootstrap/prepare.sh`, waits. No task, no `astrona submit`, no pass/fail.

## What's in the box

- One Ubuntu 24.04 qemu VM, reached with `astrona ssh astro-systemd-service-debugging`.
- `apache2` installed but **`failed`** — a tiny helper unit **`port80-hog.service`** (a `socat` listener) holds TCP 80, so `systemctl start apache2` fails with `(98)Address already in use` / `AH00072`. A real failed unit with a genuine journal trail.
- `socat`, `iproute2` (`ss`).
- `lsblk` shows `vda` (~15 GiB OS disk) and `vdb` (~366 KiB cloud-init disk). No extra disks.

## Things to try

- `systemctl status apache2` — read `Active: failed (Result: exit-code)` and the embedded log tail.
- `systemctl is-active apache2` / `is-enabled apache2` / `--failed`.
- `systemctl cat apache2` and `systemctl show apache2 -p FragmentPath -p DropInPaths`.
- `journalctl -xeu apache2` — the failure cascade; the first concrete error is the bind failure.
- `sudo ss -ltnp 'sport = :80'` — see `port80-hog` / `socat` holding the port.
- Fix it: `sudo systemctl stop port80-hog` then `sudo systemctl start apache2`; confirm with `systemctl is-active apache2`; `sudo systemctl enable --now apache2`.

## When you're done

```sh
astrona destroy systemd-service-debugging
```
