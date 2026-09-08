# section-010 / module-06 / lab-02: Service won't start — permission denied

QEMU VM for the LFCS course. `metricsd.service` runs as a dedicated non-root
user and exits `1/FAILURE` on every start because that user cannot write to
its state directory under `/var/lib`. Diagnose from the daemon's own journal
lines, fix the ownership (or use `StateDirectory=`), and confirm the service
is active, enabled, and still non-root.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-010/module-06/lab-02
```
