# Question

Solve this question on: `terminal`

The domain `metrics-cache` is **running** on this host, but it was started straight from an XML file with `virsh create`, so it is **transient**. It has no persistent definition in `/etc/libvirt/qemu/`. If this host reboots, or the domain is ever stopped, `metrics-cache` vanishes and would have to be created again from scratch.

The source XML is still on disk at `/root/metrics-cache.xml`. Work with the system libvirt instance (`qemu:///system`).

1. Make `metrics-cache` a **persistent** domain, with its definition stored at `/etc/libvirt/qemu/metrics-cache.xml`. Do it without stopping the running domain.
2. Keep its current specification exactly: 1024 MiB of memory, 1 virtual CPU, the `default` NAT network, and the existing disk `/var/lib/libvirt/images/metrics-cache.qcow2`.
3. Configure it to **autostart** when the host boots.

The grader checks that `metrics-cache` exists and shows `Persistent: yes` and `Autostart: enable` in `virsh dominfo`, that `/etc/libvirt/qemu/metrics-cache.xml` and its autostart link in `/etc/libvirt/qemu/autostart/` exist, that `Max memory` is 1048576 KiB and `CPU(s)` is 1, and that the stored definition still uses the `default` network and the `metrics-cache.qcow2` disk.
