# Solution Guide: libvirt Virtual Machine Lifecycle

This guide shows you how to define a persistent KVM domain around an existing disk image, enable autostart, and understand the difference between a graceful shutdown and a hard power-off.

---

## Step 1: Confirm libvirtd is running and the disk image is in place

```bash
sudo systemctl status libvirtd
ls -lh /var/lib/libvirt/images/inventory-db.qcow2
```

`virsh` talks to the `libvirtd` daemon over a local socket — if it isn't running, every `virsh`/`virt-install` command fails to connect before you even reach domain-specific errors.

---

## Step 2: Define the domain around the existing disk image

```bash
sudo virt-install \
  --name inventory-db \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2 \
  --import \
  --network network=default \
  --os-variant detect=on,require=off \
  --graphics none \
  --noautoconsole
```

`--import` tells `virt-install` to skip the install-media boot path entirely and treat `--disk` as already bootable — the right tool for wrapping libvirt management around an existing image rather than installing a fresh OS. `--network network=default` attaches to libvirt's built-in NAT network. `--graphics none --noautoconsole` keep this headless and non-blocking.

This disk image has no OS installed inside it — that's expected for this lab. `virt-install` still successfully defines the domain and launches the underlying QEMU process; libvirt reports it as `running` regardless of whether an OS is present to boot, since domain lifecycle state is about the QEMU process, not what's happening inside the guest.

**Note:** since this host is itself a virtualized guest, hardware-accelerated KVM (`/dev/kvm`) may not be available. `virt-install` automatically falls back to software (TCG) emulation in that case — no special flag is required, and the domain lifecycle transitions (defined → running → shut off) work correctly either way, just without hardware-accelerated performance.

---

## Step 3: Confirm the domain definition is persistent

```bash
virsh list --all
```

```
 Id   Name           State
--------------------------------
 1    inventory-db   running
```

Because `virt-install` performs a persistent define by default, `inventory-db` stays in `virsh list --all` even after it's shut off. Confirm the underlying XML was actually written to the persistent store:

```bash
sudo ls /etc/libvirt/qemu/inventory-db.xml
```

---

## Step 4: Configure autostart

```bash
sudo virsh autostart inventory-db
```

This marks the domain to start automatically when `libvirtd` starts (normally at host boot), by creating a symlink under `/etc/libvirt/qemu/autostart/` pointing back at the domain's XML. Verify:

```bash
virsh dominfo inventory-db | grep -i autostart
# Autostart:      enable
```

---

## Step 5: Confirm it's running and check actual allocated resources

```bash
virsh dominfo inventory-db
```

```
Id:             1
Name:           inventory-db
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      enable
```

`dominfo` is the authoritative source for the domain's actual configuration — 2048 MiB shows up as `2097152 KiB` (2048 × 1024).

---

## Step 6: Graceful shutdown vs. hard power-off

```bash
virsh shutdown inventory-db
```

This sends an ACPI power-button event into the guest, asking its OS to run a clean shutdown sequence. Watch the state transition:

```bash
watch -n1 virsh list --all
```

Because this disk has no guest OS installed to catch the ACPI signal, the domain will most likely **never** transition to `shut off` on its own — it will sit at `running` indefinitely, which is itself the practical lesson: `shutdown` is a *request*, not a guarantee, and a guest with no ACPI handling (or none at all, as here) simply never acts on it.

Escalate to a hard power-off:

```bash
virsh destroy inventory-db
```

`destroy` does not delete the domain's definition or disk image — it immediately halts the underlying QEMU process, the software equivalent of pulling the power cord. Unlike `shutdown`, this transitions the domain to `shut off` immediately, with no grace period, because it doesn't depend on anything inside the guest cooperating.

**The semantic difference:** `shutdown` asks the guest OS to clean up (flush disk caches, unmount filesystems, stop services) before powering off — appropriate when the guest is responsive and you can afford to wait. `destroy` is an unconditional hard stop with no cleanup opportunity for the guest — appropriate when the guest is hung, unresponsive, or has no OS installed to respond in the first place, exactly the situation here. Both leave the domain in the same final `shut off` state, but only one gave the (nonexistent, in this lab's case) guest a chance to shut down cleanly first.

```bash
virsh start inventory-db
```

Because the domain is persistently defined, `virsh start` works at any point after either kind of stop.

---

## Verification

```bash
virsh list --all
virsh dominfo inventory-db
# CPU(s): 2, Max memory: 2097152 KiB (2048 MiB), Persistent: yes, Autostart: enable

ls /etc/libvirt/qemu/autostart/inventory-db.xml
# symlink confirms autostart registration

virsh dumpxml inventory-db | grep "network='default'"
# confirms default network attachment

virsh shutdown inventory-db && sleep 5 && virsh list --all
# State likely stays "running" -- no guest OS to catch the ACPI signal

virsh destroy inventory-db
virsh list --all
# immediately "shut off" -- no grace period, unlike shutdown
```

## Command Summary

```bash
sudo systemctl status libvirtd
ls -lh /var/lib/libvirt/images/inventory-db.qcow2
sudo virt-install \
  --name inventory-db \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2 \
  --import \
  --network network=default \
  --os-variant detect=on,require=off \
  --graphics none \
  --noautoconsole
virsh list --all
sudo virsh autostart inventory-db
virsh dominfo inventory-db
virsh shutdown inventory-db
virsh destroy inventory-db
virsh start inventory-db
```
