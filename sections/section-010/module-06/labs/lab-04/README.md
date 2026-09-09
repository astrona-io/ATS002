# section-010 / module-06 / lab-04: Service won't start — failed dependency + restart flap

QEMU VM for the LFCS course. `ingest.service` is dead: its `Requires=`
backend `ingest-db.service` fails with `203/EXEC` (wrong `ExecStart` path),
so `ingest` is pulled down with it, flaps on `Restart=always`, and hits
`start-limit-hit`. Fix the upstream unit, `reset-failed` the flap, start the
chain, and `enable` **both** units for boot.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-04
```
