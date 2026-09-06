# Part 2 — Defining a domain around an existing disk

> Prerequisite: [Part 1 — The domain and the libvirt stack](./course-01-domain-and-the-libvirt-stack.md). Next: [Part 3 — Persistent vs. transient: the domain lifecycle](./course-03-persistent-vs-transient-lifecycle.md).

Part 1 said the domain XML is the definition. This part is about the fastest correct way to *produce* that XML when someone hands you a disk image that already has an operating system on it. The command is `virt-install --import`. By the end you should be able to predict what every flag puts into the resulting XML, and what the command does underneath that you could also have done by hand.

## The situation: a populated disk, no installer

Concrete instance. You have received `inventory-db.qcow2` — a qcow2 disk image someone else built, already containing a booted, configured Linux system. Your job is not to install anything. It is to wrap libvirt management around that disk: give it a name, a memory size, CPUs, a network, and register it so `virsh` can start and stop it.

Copy the image into libvirt's standard image directory first, so file paths and SELinux/AppArmor labelling line up with what the daemon expects:

```bash
# shell: host, root (writes under /var/lib/libvirt)
sudo cp inventory-db.qcow2 /var/lib/libvirt/images/
```

`/var/lib/libvirt/images/` is the default **storage pool** directory for `qemu:///system`. Putting the disk there is not mandatory, but a disk elsewhere often needs an extra `chcon`/AppArmor tweak before QEMU is allowed to open it.

## The command, flag by flag

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

`virt-install` — "virtual install" — is a Python program in the `virt-manager` project. It is a **generator**: it turns these flags into a domain XML document and then hands that document to libvirt. Each flag maps to XML:

| Flag | What it puts in the domain XML |
|---|---|
| `--name inventory-db` | `<name>inventory-db</name>` — the domain name Part 1 described |
| `--memory 2048` | `<memory unit='KiB'>2097152</memory>` — the number is MiB on the command line, stored as KiB (2048 × 1024). Part 4 revisits this unit change. |
| `--vcpus 2` | `<vcpu>2</vcpu>` |
| `--disk path=...,format=qcow2` | a `<disk type='file' device='disk'>` block pointing `<source file='...'>` at your image, with `<driver name='qemu' type='qcow2'>` |
| `--import` | *nothing directly* — it changes what `virt-install` does, see below |
| `--network network=default` | a `<interface type='network'>` block with `<source network='default'>` |
| `--os-variant detect=on,require=off` | tunes `<os>` and device model defaults (disk bus, NIC model) for the guest OS; `require=off` means "don't abort if you can't identify it" |
| `--graphics none` | no `<graphics>` element — no VNC/SPICE console |
| `--noautoconsole` | *nothing in XML* — tells `virt-install` not to attach your terminal to the guest console after starting |

State the abbreviations plainly: `--vcpus` is *virtual CPUs*, the number of CPU threads the guest sees. `qcow2` is *QEMU copy-on-write v2*, a disk image format that starts small and grows as the guest writes, and supports snapshots — as opposed to `raw`, a plain byte-for-byte disk with no metadata.

## `--import` is the flag that changes the behaviour

Without `--import`, `virt-install` expects to **install** an OS: you must also give it `--location`, `--cdrom`, or `--pxe`, and it builds a domain whose first boot points at that installation media, runs the installer, and expects a reboot into the freshly installed system.

`--import` says: *there is nothing to install — the `--disk` I gave you is already bootable.* Concretely it:

- skips all installer-media handling (no ISO, no PXE, no `--location`);
- sets the domain to boot straight from the hard disk;
- does a single define-and-start, with no install-phase reboot dance.

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

If you point `--import` at a blank qcow2, the domain defines and starts fine and then sits at a "no bootable device" prompt — the command did its job; the disk just had nothing on it.

## What it does underneath

The line worth internalising: **`virt-install --import` is a convenience wrapper, not a separate mechanism.** This one command is equivalent to doing, by hand:

```bash
# 1. write a domain XML file describing name/memory/vcpus/disk/network
# 2. sudo virsh define /path/to/that.xml      <- persistent registration (Part 3)
# 3. sudo virsh start inventory-db            <- boot it
```

So after `virt-install` returns you already have a **persistent** domain (the `define`, not `create` — Part 3 is entirely about that difference) *and* a running guest. You did not need a second command to register it.

`--network network=default` attaches the interface to libvirt's built-in NAT network. That network is itself a small managed object: a Linux bridge (usually `virbr0`), a private subnet (commonly `192.168.122.0/24`), a `dnsmasq` process giving guests DHCP leases and DNS, and iptables/nftables rules that NAT guest traffic out through the host's real interface. Guests on it can reach the outside world; the outside world cannot open connections back in without explicit port forwarding. It is the right default unless a task specifically needs the guest to appear as a real host on the physical LAN (that would be a `bridge=` interface instead).

```bash
sudo virsh net-list          # is 'default' active?
#  Name      State    Autostart   Persistent
#  default   active   yes         yes
```

If `default` shows `inactive`, a domain attached to it will fail to start with a network error — `sudo virsh net-start default` fixes it.

> [!TIP]
> **Try it — read the XML the command generated.** Right after `virt-install` returns, run `sudo virsh dumpxml inventory-db | less` and find the `<memory>`, `<vcpu>`, `<disk>`, and `<interface>` elements. Match each one back to the flag in the table above. Then `sudo cat /etc/libvirt/qemu/inventory-db.xml` — the on-disk persistent copy Part 1 described — and confirm the same values are there. You have just watched flags become a file.

> [!WARNING]
> Two mistakes that both *look* like the command failed when it did not:
> - Pointing `--disk` at a path outside `/var/lib/libvirt/images/` and getting a permission denied on start — the mandatory-access-control label is wrong, not the command. Move the image into the pool directory or relabel it.
> - Forgetting `--import` on an already-installed disk. `virt-install` then waits for installation media you never supplied and the terminal appears to hang.

> *`virt-install --import` generates the domain XML from its flags and then does a persistent `define` plus a `start` — one command, but nothing you could not have written and run by hand.*

## Reference

- `man virt-install` — every flag; read the `--disk`, `--network`, and `--import` entries in full, and the "IMPORT INSTALL" example near the bottom.
- `man virsh` — the `net-list`, `net-start`, `net-info` sub-commands for inspecting the `default` network.
- `https://libvirt.org/formatnetwork.html` — how the NAT `default` network is itself defined in XML, including its `dnsmasq` DHCP range.
