# section-050 / module-01: Third-Party Repositories & Package Pinning

QEMU VM for the LFCS course — trusting a third-party APT repository the modern `signed-by` way (no `apt-key`), installing an exact pinned version of a package from it, and holding that version so a routine upgrade cannot move it. The "vendor" repository is a fully real, self-contained local APT repository running on the VM itself, so the lab has no dependency on any real external host.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-01/labs/lab-01
```
