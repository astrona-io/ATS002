# Defining A Domain Around An Existing Disk

Astronaut, someone hands you a ship's cargo hold that is already packed: a disk image with an operating system on it. Your job is to give it a blueprint and register it in the hangar. The fastest correct way to write that domain XML is `virt-install --import`. By the end of this part you can predict what each flag puts into the XML, and what the command does underneath that you could also do by hand.

## The situation: a populated disk, no installer

You have received `inventory-db.qcow2`, a disk image someone else built. **qcow2** (QEMU copy-on-write version 2) is a disk format stored as one file: the smaller ship's cargo hold, kept as a single file in the hangar. It starts small and grows as the guest writes, and it supports snapshots. The other common format, `raw`, is a plain byte-for-byte disk with no extra information.

This image already holds an installed, configured Linux system. You do not install anything. You wrap libvirt management around the disk: give it a name, a memory size, CPUs and a network, and register it so `virsh` can start and stop it.

Copy the image into libvirt's standard image folder first, so the file paths and the security labels match what the daemon expects:

<!-- astrona:playground:renew -->

```bash
# shell: host, root (writes under /var/lib/libvirt)
sudo cp inventory-db.qcow2 /var/lib/libvirt/images/
```

`/var/lib/libvirt/images/` is the default **storage pool** folder for `qemu:///system`, the place the hangar keeps its cargo holds. You do not have to use it. But a disk somewhere else often needs an extra SELinux or AppArmor change before the security chief lets QEMU open it.

## The command, flag by flag

`virt-install` ("virtual install") is a Python program from the `virt-manager` project. It is a **generator**: it turns its flags into a domain XML document and then hands that document to libvirt.

### The full command

```bash
# shell: host, root — builds XML, defines the domain, starts it
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

### What each flag writes

Each flag maps to a piece of the XML:

| Flag | What it puts in the domain XML |
|---|---|
| `--name inventory-db` | `<name>inventory-db</name>` — the domain name |
| `--memory 2048` | `<memory unit='KiB'>2097152</memory>` — the number is MiB on the command line, stored as KiB (2048 × 1024) |
| `--vcpus 2` | `<vcpu>2</vcpu>` |
| `--disk path=...,format=qcow2` | a `<disk type='file' device='disk'>` block pointing `<source file='...'>` at your image, with `<driver name='qemu' type='qcow2'>` |
| `--import` | *nothing directly* — it changes what `virt-install` does, see below |
| `--network network=default` | a `<interface type='network'>` block with `<source network='default'>` |
| `--os-variant detect=on,require=off` | tunes `<os>` and device model defaults (disk bus, NIC model) for the guest OS; `require=off` means "don't abort if you can't identify it" |
| `--graphics none` | no `<graphics>` element — no VNC/SPICE console |
| `--noautoconsole` | *nothing in XML* — tells `virt-install` not to attach your terminal to the guest console after starting |

`--vcpus` means *virtual CPUs*, the number of CPU threads the guest sees. The memory unit changes on the way in: you type MiB, and libvirt stores KiB.

## `--import` is the flag that changes the behaviour

Without `--import`, `virt-install` expects to **install** an operating system. Then you must also give it `--location`, `--cdrom` or `--pxe`. It builds a domain that first boots from that installation media, runs the installer, and then reboots into the new system.

`--import` says: *there is nothing to install, because the `--disk` I gave you can already boot.* In practice it:

- skips everything about installation media (no ISO, no PXE network boot, no `--location`);
- sets the domain to boot straight from the hard disk;
- defines and starts the domain once, with no install-time reboot.

```
without --import:                with --import:

  media (ISO/PXE) boot             disk boot
        |                              |
   run installer                  guest is already installed
        |                              |
   reboot into disk               done
        |
   guest usable
```

If you point `--import` at an empty qcow2, the domain is defined and starts fine, and then waits at a "no bootable device" message. The command did its job; the disk just had nothing on it.

## What it does underneath

The idea worth remembering: **`virt-install --import` is a shortcut, not a separate mechanism.** This section shows the steps it saves you, and the network it plugs the guest into.

### Three steps in one command

The one command does the same as these steps by hand:

```bash
# 1. write a domain XML file describing name/memory/vcpus/disk/network
# 2. sudo virsh define /path/to/that.xml      <- persistent registration
# 3. sudo virsh start inventory-db            <- boot it
```

So when `virt-install` returns, you already have a **persistent** domain (made with `define`, not `create`) *and* a running guest. You do not need a second command to register it.

### The `default` NAT network

`--network network=default` connects the guest to libvirt's built-in **NAT network** (network address translation: guests share the host's own address when they talk to the outside). That network is a small managed object of its own: a Linux bridge (usually `virbr0`), a private subnet (often `192.168.122.0/24`), a `dnsmasq` process that hands guests their addresses (DHCP) and answers name lookups (DNS), and firewall rules (iptables or nftables) that translate guest traffic out through the host's real network card. Guests on it can reach the outside world. The outside world cannot open connections back in unless you set up port forwarding. It is the right default unless a task needs the guest to look like a real host on the physical network; that would be a `bridge=` interface instead.

```bash
sudo virsh net-list          # is 'default' active?
#  Name      State    Autostart   Persistent
#  default   active   yes         yes
```

If `default` shows `inactive`, a domain that uses it fails to start with a network error. `sudo virsh net-start default` fixes it.

## See it in your playground

The playground staged an empty `/var/lib/libvirt/images/inventory-db.qcow2` for exactly this. You define a domain around it, then look at the XML and the process it produced.

### Define the domain around the staged disk

On the host, run:

```sh
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

Expect something like:

```text
WARNING  KVM acceleration not available, using 'qemu'
Starting install...
Domain creation completed.
```

The KVM warning is expected. This host is itself a virtual machine, so libvirt falls back to software emulation (TCG, the Tiny Code Generator inside QEMU). It changes nothing about the lifecycle. `sudo virsh list --all` now shows `inventory-db` as `running`. The guest console would show "no bootable device" because the disk is empty. That is fine: this module is about the domain, not what boots inside it.

### Flags became a file, and a process

The command built the XML, defined it and started it. Now you can see all three layers at once: the daemon tracking the domain, and a real `qemu-system` process under it. On the host:

```sh
sudo virsh dumpxml inventory-db | grep -E '<memory|<vcpu|<source (file|network)'
sudo cat /etc/libvirt/qemu/inventory-db.xml | grep -E '<memory|<vcpu'
pgrep -af qemu-system | head -1
```

Expect something like:

```text
  <memory unit='KiB'>2097152</memory>
  <vcpu placement='static'>2</vcpu>
    <source file='/var/lib/libvirt/images/inventory-db.qcow2'/>
    <source network='default'/>
  <memory unit='KiB'>2097152</memory>
  <vcpu placement='static'>2</vcpu>
12874 /usr/bin/qemu-system-x86_64 -name guest=inventory-db,debug-threads=on -machine ...
```

`--memory 2048` (MiB on the command line) is stored as `2097152` KiB in both the live XML and the file on disk. The process number and the paths in the `qemu-system` line will be different on your host. The daemon built that whole QEMU command line from the XML; you never typed any of it.

## Common pitfalls

> [!WARNING]
> - **Permission denied on start for a disk outside `/var/lib/libvirt/images/`.** It looks like the command failed, but the mandatory access control label is wrong, not the command. Move the image into the pool folder or relabel it.
> - **Forgetting `--import` on an already-installed disk.** `virt-install` then waits for installation media you never supplied, and the terminal seems to hang although nothing failed.
> - **The `default` network is `inactive`.** A domain attached to it fails to start with a network error. Start it with `sudo virsh net-start default`.

> *`virt-install --import` writes the domain XML from its flags, then does a persistent `define` plus a `start`. It is one command, but nothing you could not write and run by hand.*
