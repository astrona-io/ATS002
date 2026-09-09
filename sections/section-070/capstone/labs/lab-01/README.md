# section-070 / capstone: Section 070 Capstone — Zypper Research and Action

QEMU VM for the LFCS course — the section 070 capstone, combining real openSUSE zypper research (`search`, `info`, installed-only filtering) with real maintenance action (`patch`, `install`, `remove`, `history`), all inside a Dockerized `opensuse/leap:15.6` sandbox on the Ubuntu host.

## Working Inside zypperbox

This lab's VM boots Ubuntu 24.04 — that's simply the only base image this platform provides. There is no zypper on the Ubuntu host itself. Instead, bootstrap installs Docker and starts a long-lived container named `zypperbox` from the real `opensuse/leap:15.6` image. All zypper work happens inside that container, which you reach with:

```bash
docker exec -it zypperbox bash
```

Everything inside that shell is a genuine openSUSE Leap 15.6 environment — real `zypper`, real RPM database, real openSUSE repositories. Run every command in this lab's question from inside that `docker exec` shell, not on the Ubuntu host directly.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/capstone/labs/lab-01
```
