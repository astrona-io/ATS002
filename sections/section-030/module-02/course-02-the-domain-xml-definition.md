# The Domain XML Definition

Astronaut, every smaller ship in the hangar has a blueprint, and the hangar control system builds the ship from it each time it launches. In libvirt that blueprint is one XML document per domain. This part shows what is in it, why a running domain has two versions of it, and where the file lives on disk.

## The domain XML is the definition; everything else refers to it

Every persistent domain is described by one XML document, the **domain XML**. It is the source of truth for the domain's shape: memory, virtual CPUs, disks, network and boot order. `virsh` commands are structured ways to read that document or change it.

### Read and edit the blueprint

The domain XML is the smaller ship's blueprint. It states how much memory the ship gets, how many CPUs, which disk it boots from and which network it plugs into, and everything `virsh` does later refers back to it. Two commands work with it:

<!-- astrona:playground:renew -->

```bash
sudo virsh dumpxml inventory-db     # print the live definition to stdout
sudo virsh edit inventory-db        # open the persistent definition in $EDITOR, validate on save
```

`virsh edit` opens the definition in your text editor. When you save, libvirt checks the XML and stores it. Unlike a paper blueprint, this one changes over time, and a running domain also has a second, expanded copy of it.

### Two versions of a running domain's XML

A running domain has **two versions** of its XML. Mixing them up wastes debugging time:

- **On-disk, or persistent**: what the domain will look like the next time it starts cold. This is the file `virsh edit` opens.
- **Live, or in memory**: the persistent definition plus everything the daemon and QEMU filled in at start time, such as the real PCI addresses of each device, the actual VNC port and the exact machine type. `virsh dumpxml` of a *running* domain prints this expanded version.

When you edit the persistent file, the running guest does not change. The change takes effect at the next full start. A reboot from inside the guest is not enough; you need a `virsh destroy` and `virsh start` cycle, or a `virsh shutdown` and `virsh start` cycle. "Next cold start" is the key phrase whenever you change a domain's shape.

## Where the definition lives on disk

For `qemu:///system`, libvirt keeps the persistent XML files in one folder. Knowing it lets you prove that a domain really is registered.

### The folder

```bash
sudo ls -l /etc/libvirt/qemu/
# inventory-db.xml
# networks/            <- the 'default' NAT network lives here
```

`/etc/libvirt/qemu/inventory-db.xml` **is** the domain `inventory-db`. Two rules follow from that:

- Do **not** change that file with a text editor. The daemon keeps the definitions in memory and only reads this folder again when it restarts, so your change is overwritten the next time anything calls `virsh define`. Use `virsh edit`, which locks the file, checks it and reloads it.
- Copying `inventory-db.xml` to another host is *most* of a move, but not all of it. libvirt keeps some settings outside that file, such as autostart and snapshots. Autostart, for example, is a separate link file in its own folder.

### See it in your playground

The `inventory-db` domain does not exist in your playground yet; you build it soon. But the rule "a definition is a file on disk, and `virsh` reads it through the daemon" already applies to the `default` NAT network that the playground set up. A **NAT network** is a private network for guests that reaches the outside world through the host's own connection. On the playground host, run:

```sh
sudo ls /etc/libvirt/qemu/            # no domain XML yet
sudo ls /etc/libvirt/qemu/networks/   # but the 'default' network is here
diff <(sudo virsh net-dumpxml default) <(sudo cat /etc/libvirt/qemu/networks/default.xml)
```

Expect something like:

```text
networks
default.xml
1c1
< <network>
---
> <network connections='1'>
```

The only difference is a live-only `connections='1'` attribute that the daemon adds in memory. That is the persistent-versus-live split from above, shown here for a network instead of a domain. After you define `inventory-db`, `sudo ls /etc/libvirt/qemu/` shows `inventory-db.xml` next to `networks/`.

## Common pitfalls

> [!WARNING]
> - **Changing `/etc/libvirt/qemu/<name>.xml` with a text editor.** The daemon does not read it again, and the next `virsh define` overwrites it. Use `virsh edit`.
> - **Expecting a `virsh edit` change on a running guest.** The persistent definition only takes effect at the next cold start (`virsh destroy` or `virsh shutdown`, then `virsh start`). A reboot inside the guest is not enough.
> - **Reading `virsh dumpxml` of a running domain as the stored definition.** It prints the live, expanded version. The file under `/etc/libvirt/qemu/` is the stored one.

> *A domain's XML file under `/etc/libvirt/qemu/` is its definition. `virsh` reads and changes it through the daemon, so never touch the file directly.*
