# section-060 / module-02 / lab-02: RPM database — corruption look-alike

QEMU VM for the LFCS course, running the `rpmbox` Rocky Linux 9 container.
Companion to lab-01's real corruption: here `dnf check` fails loudly, but
the RPM database is **not** corrupt — a package was left with an unmet
dependency. The student must read the errors (they name a package, not the
database), rule out corruption and disk space, and resolve the dependency
instead of reaching for `rpm --rebuilddb`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-060/module-02/lab-02
```
