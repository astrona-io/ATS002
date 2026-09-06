# Overview: PLAYGROUND — libvirt Virtual Machine Lifecycle

> Declared in [`../config.yaml`](../config.yaml) under `metadata.docs.guide`.

This is a **playground**, not a lab. The environment starts clean, runs
`bootstrap/prepare.sh`, and then waits. There is no task, no `astrona submit`,
and no pass/fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single Ubuntu 24.04 qemu VM — the **host** — reached with
  `astrona ssh astro-libvirt-vm-lifecycle`.
- **libvirt** (`libvirt-daemon-system`, `libvirt-clients`), **virt-install**
  (`virtinst` package), and **QEMU** (`qemu-system-x86`, `qemu-utils`)
  installed. `libvirtd` is running and its `default` NAT network is active and
  set to autostart.
- An **empty 2 GiB qcow2** staged at
  `/var/lib/libvirt/images/inventory-db.qcow2` — deliberately with no OS
  inside it, so `virt-install --import` defines and starts a domain that then
  sits at "no bootable device". That is enough to exercise every lifecycle
  command in the module.
- `lsblk` on the host shows `vda` (the ~20 GiB OS disk) and `vdb` (a ~366 KiB
  cloud-init disk). There are no extra attached disks. The
  `inventory-db.qcow2` above is a file on `vda`, not a separate block device.

Nested KVM (`/dev/kvm`) may or may not be present on this host. It does not
matter: `virsh` / `virt-install` fall back to software (TCG) emulation, and
every state transition the module teaches — `defined → running → shut off`,
`shutdown` vs `destroy` — behaves identically either way.

Use the system libvirt instance, not the per-user one:

```sh
export LIBVIRT_DEFAULT_URI=qemu:///system   # or just prefix everything with sudo
```

## Things to try

- Define a domain around the staged disk and watch flags become XML:
  `sudo virt-install --name inventory-db --memory 2048 --vcpus 2 --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2 --import --network network=default --graphics none --noautoconsole`,
  then `sudo virsh dumpxml inventory-db` and
  `sudo cat /etc/libvirt/qemu/inventory-db.xml`.
- Compare persistent and transient: `sudo virsh define` a second domain vs
  `sudo virsh create` it, stop both, and run `sudo virsh list --all`.
- `sudo virsh autostart inventory-db`, then `ls -l /etc/libvirt/qemu/autostart/`
  — see the switch is one symlink.
- `sudo virsh dominfo inventory-db` — read `State`, `Max memory` (in KiB),
  `Persistent`, `Autostart`.
- `sudo virsh shutdown inventory-db` (nothing happens — no OS to catch the ACPI
  event), then `sudo virsh destroy inventory-db` (immediate). `sudo virsh start`
  brings it back because it is persistently defined.

## When you're done

```sh
astrona destroy libvirt-vm-lifecycle
```

(`astrona destroy` takes the environment name, not the config path. The running
machine is `astro-libvirt-vm-lifecycle`; the environment name here is
`libvirt-vm-lifecycle`.)
