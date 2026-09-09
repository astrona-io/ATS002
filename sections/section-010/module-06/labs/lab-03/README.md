# section-010 / module-06 / lab-03: Service won't start — port already in use

QEMU VM for the LFCS course. `webreport.service` (an HTTP server on TCP 8080)
fails with `(98)Address already in use` because a leftover unit already holds
the port. Use `ss -ltnp` to find the squatter, disable it for good, start
`webreport`, and confirm it is active, enabled, and serving on 8080.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-03
```
