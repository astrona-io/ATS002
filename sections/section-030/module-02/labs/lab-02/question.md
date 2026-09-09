# Question

Solve this question on: `terminal`

The domain `metrics-cache` is **running** on this host, but it was started
straight from an XML file with `virsh create` — so it is **transient**. It
has no persistent definition in `/etc/libvirt/qemu/`: if this host reboots,
or the domain is ever stopped, `metrics-cache` vanishes completely and would
have to be recreated from scratch.

The source XML is still on disk at `/root/metrics-cache.xml`.

1. Promote `metrics-cache` to a **persistent** domain **without stopping the
   running instance**. Keep its current specification exactly: 1024 MiB
   memory, 1 vCPU, the `default` NAT network, and the existing disk
   `/var/lib/libvirt/images/metrics-cache.qcow2`.
2. Configure it to **autostart** when the host boots.
3. Confirm the persistent definition now exists on disk and that the domain
   would survive being shut off.

Do not change the memory, vCPU count, disk, or network attachment.
