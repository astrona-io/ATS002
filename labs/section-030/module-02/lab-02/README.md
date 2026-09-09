# section-030 / module-02 / lab-02: Transient → Persistent domain

QEMU VM for the LFCS course. `metrics-cache` is running but **transient**
(started with `virsh create`, no definition on disk). Promote it to a
**persistent** domain in place with `virsh define /root/metrics-cache.xml` —
without stopping it — then `virsh autostart` it. Confirm
`/etc/libvirt/qemu/metrics-cache.xml` now exists and the domain survives a
`virsh destroy`.

## Run

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c labs/section-030/module-02/lab-02
```
