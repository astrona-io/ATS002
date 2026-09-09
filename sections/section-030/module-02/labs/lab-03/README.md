# section-030 / module-02 / lab-03: Reconfigure a persistent domain

QEMU VM for the LFCS course. The persistent domain `web-db` is
under-provisioned (512 MiB, 1 vCPU) and shut off. Raise it to **2048 MiB /
2 vCPU in the persistent config** — `virsh edit web-db`, or
`virsh setmaxmem`/`setmem`/`setvcpus` with `--config` — then start it and
verify with `virsh dominfo`. A bare `virsh setmem` without `--config` only
changes the running domain and does not survive a reboot.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-03
```
