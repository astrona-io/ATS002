# lab-071: Zypper Basic Package Operations

QEMU VM for the LFCS course — real openSUSE zypper package management (repository refresh, patches vs. raw updates, install/remove, and operation history) running inside a Dockerized `opensuse/leap:15.6` sandbox on the Ubuntu host.

## Working Inside zypperbox

This lab's VM boots Ubuntu 24.04 — that's simply the only base image this platform provides. There is no zypper on the Ubuntu host itself. Instead, bootstrap installs Docker and starts a long-lived container named `zypperbox` from the real `opensuse/leap:15.6` image. All zypper work happens inside that container, which you reach with:

```bash
docker exec -it zypperbox bash
```

Everything inside that shell is a genuine openSUSE Leap 15.6 environment — real `zypper`, real RPM database, real openSUSE repositories. Run every command in this lab's question from inside that `docker exec` shell, not on the Ubuntu host directly.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-071
```
