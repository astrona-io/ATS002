# Overview: libvirt Virtual Machine Lifecycle Playground

This is a **playground**, not a lab. The training ship starts clean, runs its preparation script once, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, run `astrona destroy`, and start over.

## What's in the box

Your playground is one hangar, ready for smaller ships:

- A single Ubuntu 24.04 `qemu` virtual machine, the **host**. Reach it with `astrona ssh astro-libvirt-vm-lifecycle`.
- **libvirt** (the `libvirt-daemon-system` and `libvirt-clients` packages), **virt-install** (the `virtinst` package) and **QEMU** (`qemu-system-x86` and `qemu-utils`), all installed. `libvirtd` is running, and its `default` NAT network is active and set to autostart.
- An **empty 2 GiB qcow2 disk** at `/var/lib/libvirt/images/inventory-db.qcow2`. It has no operating system on purpose, so `virt-install --import` defines and starts a domain that then waits at "no bootable device". That is enough to try every lifecycle command in the module.
- `lsblk` on the host shows `vda` (the operating system disk, about 20 GiB) and `vdb` (a small cloud-init disk of about 366 KiB). There are no extra disks. The `inventory-db.qcow2` file above is a file on `vda`, not a separate block device.

Nested KVM (`/dev/kvm`) may or may not be there on this host. It does not matter: `virsh` and `virt-install` fall back to software emulation (TCG), and every state change the module teaches, from defined to running to shut off, and `shutdown` versus `destroy`, behaves the same way.

Use the system libvirt instance, not the private one for your user:

```sh
export LIBVIRT_DEFAULT_URI=qemu:///system   # or just prefix everything with sudo
```

## Things to try

- Define a domain around the staged disk and watch flags become XML:
  `sudo virt-install --name inventory-db --memory 2048 --vcpus 2 --disk path=/var/lib/libvirt/images/inventory-db.qcow2,format=qcow2 --import --network network=default --graphics none --noautoconsole`,
  then `sudo virsh dumpxml inventory-db` and
  `sudo cat /etc/libvirt/qemu/inventory-db.xml`.
- Compare persistent and transient: `sudo virsh define` a second domain, `sudo virsh create` another one, stop both, and run `sudo virsh list --all`.
- Run `sudo virsh autostart inventory-db`, then `ls -l /etc/libvirt/qemu/autostart/`, and see that the switch is one symlink.
- Run `sudo virsh dominfo inventory-db` and read `State`, `Max memory` (in KiB), `Persistent` and `Autostart`.
- Run `sudo virsh shutdown inventory-db` (nothing happens, because there is no operating system to catch the ACPI event), then `sudo virsh destroy inventory-db` (immediate). `sudo virsh start` brings it back, because it is persistently defined.

## When you're done

```sh
astrona destroy libvirt-vm-lifecycle
```

`astrona destroy` takes the playground's name, not the folder path. The terminal command uses `astro-libvirt-vm-lifecycle`; the `astro-` prefix is optional there. The name for `astrona destroy` is `libvirt-vm-lifecycle`.
