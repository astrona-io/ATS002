# libvirt Virtual Machine Lifecycle

A container shares the host kernel. A virtual machine does not — it boots its own kernel, runs its own init system, and behaves, from the inside, exactly like a physical computer. Managing that is a genuinely different discipline from managing containers, and on Linux the tool that does it is **libvirt**: a daemon (`libvirtd`) and a command-line client (`virsh`) that sit on top of the KVM hypervisor and manage what libvirt calls a **domain** — its own word for "one managed virtual machine."

Think of a domain's XML definition as a virtual machine's birth certificate. It states, in one document, exactly how much memory it's entitled to, how many virtual CPUs, which disk image it boots from, and which network it plugs into. Everything `virsh` does afterward — starting it, stopping it, checking on it — refers back to that one document.

---

## Defining a Domain Around an Existing Disk

Not every VM starts life by installing an operating system from scratch. Frequently, you're handed an already-populated disk image — a qcow2 file someone else built, or one you're migrating — and your job is just to wrap libvirt management around it. That's exactly what `virt-install --import` is for:

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

`--import` is the flag doing the real work here: it tells `virt-install` to skip the entire installation-media boot path (no PXE, no CD-ROM ISO) and instead treat the `--disk` you handed it as already bootable. `--network network=default` attaches the domain to libvirt's built-in NAT network — a virtual bridge (typically `virbr0`) with its own DHCP range, and the simplest choice unless a task specifically calls for bridged networking onto the physical LAN. `--graphics none` plus `--noautoconsole` keep this headless and non-blocking — appropriate for a server-style guest you intend to manage over SSH or a serial console, not a GUI desktop.

Worth internalizing: `virt-install` is a *convenience wrapper*, not a separate concept from the lower-level `virsh` commands. Under the hood, this single command both builds the domain's XML and performs the equivalent of a persistent define followed by a start.

---

## Persistent vs. Transient: The Distinction That Actually Matters

This is the single most consequential idea in this module, so it's worth stating plainly before anything else: **`virsh define` and `virsh create` both accept the exact same XML input — but only one of them survives the domain being stopped.**

```bash
sudo virsh define /path/to/domain.xml   # persistent — survives being stopped
sudo virsh create /path/to/domain.xml   # transient — gone once it stops
```

A **persistent** domain (defined) has its XML written into libvirt's own permanent config store. It shows up in `virsh list --all` indefinitely — running or not — until you explicitly `virsh undefine` it. A **transient** domain (created) exists only in libvirtd's memory for as long as it's running. The moment it stops — clean shutdown, crash, or a host reboot — its definition evaporates completely. There's nothing left to restart.

`virt-install`, run the way it was above (no transient-specific flag), performs a persistent define by default. Confirm the definition actually landed on disk:

```bash
sudo ls /etc/libvirt/qemu/inventory-db.xml
```

That file *is* the domain's persistent definition. `virsh dumpxml inventory-db` prints the live, in-memory version instead (which can include runtime details, like actual PCI addresses assigned by QEMU, that the on-disk file doesn't carry) — and `virsh edit inventory-db` opens the persistent file directly for hand editing, validating your changes on save.

Confusing these two is the classic mistake in this domain area: define a VM meant to survive maintenance windows using `virsh create` (or forget that a bare `virt-install --transient` invocation behaves the same way), and the VM appears to vanish the instant it powers off — which, under exam pressure, can look indistinguishable from data loss.

---

## Autostart: Metadata, Not an XML Field

Getting a domain to start automatically with the host is a separate step from defining it — and it's easy to forget under time pressure precisely because it's separate:

```bash
sudo virsh autostart inventory-db
```

Under the hood, this creates a symlink in `/etc/libvirt/qemu/autostart/` pointing back at the domain's persistent XML in `/etc/libvirt/qemu/`. That's the detail worth remembering: autostart is tracked by libvirt as its own piece of metadata, not a field baked into the portable domain XML itself. Copy a domain's `dumpxml` output to a different host, and the autostart setting does not travel with it — you'd need to re-run `virsh autostart` there separately.

Verify it took effect, and verify disabling it removes the same symlink:

```bash
virsh dominfo inventory-db | grep -i autostart
# Autostart:      enable
```

---

## Reading the Domain's True State

`virsh dominfo` is the authoritative source for a domain's actual configuration — not your memory of the flags you typed when you defined it:

```bash
virsh dominfo inventory-db
```

```
Id:             3
Name:           inventory-db
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Autostart:      enable
```

Note the units: `Max memory` is reported in KiB, so 2048 MiB shows up as `2097152 KiB` (2048 × 1024). If a task specifies memory in MiB and you're eyeballing `dominfo` output, do that conversion before assuming a mismatch. Also don't confuse `Max memory` with `Used memory` — for a domain without memory ballooning configured, these will usually match, but they answer different questions, and a task verifying "was 2048 MiB allocated" is asking about `Max memory`, the domain's actual entitlement.

---

## Graceful Shutdown vs. Hard Power-Off

Stopping a domain is not one operation — it's two, with genuinely different consequences, and the distinction between them is a favorite exam trap.

```bash
virsh shutdown inventory-db
```

This sends an ACPI power-button *event* into the guest. It does not stop the VM itself — it politely asks the guest operating system's own init system (systemd, on most modern Linux guests) to catch that signal and run its normal, clean shutdown sequence: stop services, flush caches, sync and unmount filesystems, then power off. Because it depends on the *guest* cooperating, `shutdown` is asynchronous — the command returns immediately, and you have to poll to see whether it actually worked:

```bash
watch -n1 virsh list --all
```

If the guest has no ACPI handling configured, is hung, or is otherwise unresponsive, the domain simply never transitions to `shut off` — it sits at `running` indefinitely, waiting for a cooperation that will never come. That's when you escalate:

```bash
virsh destroy inventory-db
```

Despite the alarming name, `destroy` does not delete anything — not the domain's persistent definition, not its disk image. It immediately halts the underlying QEMU process, the exact software equivalent of pulling the power cord on a physical machine. The guest gets no chance to flush disk caches or stop services cleanly. That's an acceptable, sometimes necessary tradeoff for a genuinely hung guest — but it's the same real-world risk as yanking power from physical hardware, and it should never be your default first move against a guest that might still respond to a polite request.

Think of it as the difference between asking someone to finish what they're doing and leave the room, versus cutting the lights and locking the door regardless of whether they're still mid-sentence. Both end with an empty room. Only one gives the occupant a chance to save their work first.

Because the domain is persistently defined, either path leaves you free to bring it back at any point:

```bash
virsh start inventory-db
```

---

## Self-Check and Verification

To prove you can manage a domain's full lifecycle:

1. Wrap `virt-install --import` around an existing qcow2 disk image to define a new persistent domain with a specific memory and vCPU allocation.
2. Confirm the domain survived being stopped by checking `virsh list --all` and the presence of its XML under `/etc/libvirt/qemu/`.
3. Enable autostart with `virsh autostart` and verify both `virsh dominfo` and the symlink under `/etc/libvirt/qemu/autostart/`.
4. Issue a graceful `virsh shutdown` and poll `virsh list --all` until the state changes (or confirm it never does, for a guest with no ACPI handling).
5. Start the domain again, then issue a `virsh destroy` and observe that it transitions to `shut off` immediately, with no grace period.
6. Explain, in your own words, why `destroy` is not the same operation as `undefine`.
