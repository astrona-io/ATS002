# section-070 / module-02: Zypper Package Information Lookup

QEMU VM for the LFCS course — real openSUSE zypper research commands (`search`, `info`, `what-provides`, and filtered installed-only search) running inside a Dockerized `opensuse/leap:15.6` sandbox on the Ubuntu host. Entirely read-only: nothing is installed, removed, or updated anywhere in this lab.

## Working Inside zypperbox

This lab's VM boots Ubuntu 24.04 — that's simply the only base image this platform provides. There is no zypper on the Ubuntu host itself. Instead, bootstrap installs Docker and starts a long-lived container named `zypperbox` from the real `opensuse/leap:15.6` image. All zypper work happens inside that container, which you reach with:

```bash
docker exec -it zypperbox bash
```

Everything inside that shell is a genuine openSUSE Leap 15.6 environment — real `zypper`, real RPM database, real openSUSE repositories. Run every command in this lab's question from inside that `docker exec` shell, not on the Ubuntu host directly.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-02/labs/lab-01
```
