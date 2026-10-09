# Wrap-Up: Mission Debrief

Well flown, astronaut. You have registered, launched, inspected and landed smaller ships in your hangar. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about managing virtual machines with libvirt: the domain, its blueprint, and the lifecycle commands that act on it.

**From [The Domain And The libvirt Stack](./course-01-domain-and-the-libvirt-stack.md):**

- A domain is libvirt's word for one virtual machine. Use its name or UUID, never the Id, which changes at every start.
- `virsh` is a thin client. It talks to the libvirt daemon (`libvirtd` or `virtqemud`), which starts one `qemu-system-x86_64` process per running domain.
- `qemu:///system` and `qemu:///session` are two separate sets of domains. Use `sudo virsh` or export `LIBVIRT_DEFAULT_URI=qemu:///system`.

**From [The Domain XML Definition](./course-02-the-domain-xml-definition.md):**

- The domain XML is the definition. `virsh dumpxml` prints it, `virsh edit` changes it safely.
- A running domain has a persistent version and a live, expanded version. Persistent changes take effect at the next cold start.
- The persistent file is `/etc/libvirt/qemu/<name>.xml`. Never change it with a text editor.

**From [Defining A Domain Around An Existing Disk](./course-03-defining-around-an-existing-disk.md):**

- `virt-install --import` writes the XML from its flags, then defines and starts the domain.
- `--import` skips installation media and boots straight from the given disk.
- `--memory` takes MiB and the XML stores KiB. The `default` network is a NAT network that must be `active`.

**From [Persistent Vs Transient: The Domain Lifecycle](./course-04-persistent-vs-transient-lifecycle.md):**

- `define` registers and does not start; `create` starts and does not register.
- A persistent domain has a `shut off` resting state. A transient domain is gone the moment it stops.
- Prove persistence with the file under `/etc/libvirt/qemu/` or `Persistent: yes` in `virsh dominfo`.

**From [Autostart And Reading A Domain's True State](./course-05-autostart-and-reading-true-state.md):**

- `virsh autostart` creates a symlink in `/etc/libvirt/qemu/autostart/`. It is not in the XML, so it does not travel with it.
- `virsh dominfo` shows the real state. Its memory is in KiB, and `Max memory` is the entitlement.
- `<memory>` is the maximum and `<currentMemory>` the current allocation; raise both to give a domain more memory.

**From [Graceful Shutdown Vs Hard Power-Off](./course-06-graceful-shutdown-vs-hard-destroy.md):**

- `virsh shutdown` sends an ACPI request, returns at once, and can be ignored by the guest. Check with `virsh list --all`.
- `virsh destroy` ends the QEMU process at once and always works, but the guest gets no clean shutdown. It deletes nothing.
- `virsh undefine` deletes the definition. On a running domain it turns it into a transient one.

### The most common mistakes, all in one place

These are the traps of the whole module:

- **`create` instead of `define`** for a virtual machine that must survive a reboot: it works until it stops, then vanishes.
- **Forgetting `virsh autostart`**: a defined domain does *not* come up on host boot by itself.
- **Expecting autostart in the XML**: it is a symlink, so copying the `dumpxml` output does not carry it.
- **Misreading `dominfo` memory**: KiB, not MiB, and `Max memory` (entitlement), not `Used memory`.
- **`destroy` as the default stop**: it is the escalation; `shutdown` comes first.
- **Expecting `virsh shutdown` to wait**: it returns at once; check again to confirm.
- **Mixing up `destroy` and `undefine`**: one stops the process, the other deletes the definition.

## Your missions

You proved each skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Transient to Persistent Domain Lab](./labs/lab-02/README.md) | Autostart And Reading A Domain's True State | make a running transient domain persistent without stopping it, and turn on autostart |
| [Reconfigure a Persistent Domain Lab](./labs/lab-03/README.md) | Autostart And Reading A Domain's True State | raise a domain's memory and virtual CPUs in its stored definition, so the change survives a reboot |
| [libvirt Virtual Machine Lifecycle Lab](./labs/lab-01/README.md) | Graceful Shutdown Vs Hard Power-Off | define a persistent domain around an existing disk with an exact size and network, and turn on autostart |

If you skipped one, go back to it now. Each mission is short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You defined a domain with <code>sudo virsh</code>, but <code>virsh list --all</code> as yourself shows nothing. Why?</summary>

As a normal user, `virsh` may connect to `qemu:///session`, a separate and usually empty set of domains. Run `sudo virsh list --all`, or export `LIBVIRT_DEFAULT_URI=qemu:///system`. `virsh uri` shows which one you reached.
</details>

<details>
<summary>2. What does <code>virt-install --import</code> do underneath?</summary>

It writes a domain XML document from its flags, registers it persistently (like `virsh define`) and starts it (like `virsh start`). `--import` tells it the disk can already boot, so it skips all installation media.
</details>

<details>
<summary>3. A domain was started with <code>virsh create</code>. What happens when it stops?</summary>

It vanishes. A transient domain only exists in the daemon's memory, so after any stop it no longer appears in `virsh list --all`, and `virsh start` has nothing to start. The disk image stays on disk.
</details>

<details>
<summary>4. How do you make a running transient domain persistent without stopping it?</summary>

Run `virsh define` on its XML file (or on the output of `virsh dumpxml`, saved before it stops). libvirt attaches the persistent definition to the running domain, and `virsh dominfo` then shows `Persistent: yes`.
</details>

<details>
<summary>5. Where does <code>virsh autostart</code> store its setting?</summary>

As a symlink in `/etc/libvirt/qemu/autostart/` that points at the domain's XML file. It is not inside the XML, so copying the XML to another host does not carry it.
</details>

<details>
<summary>6. A task says 2048 MiB. <code>virsh dominfo</code> shows <code>Max memory: 2097152 KiB</code>. Is that wrong?</summary>

No. `dominfo` reports KiB, and 2048 × 1024 = 2097152. `Max memory` is the entitlement the task checks.
</details>

<details>
<summary>7. <code>virsh shutdown</code> reported success, but the domain is still <code>running</code> a minute later. What now?</summary>

The guest did not act on the ACPI request, because it has no handler, is hung, or has no operating system. Escalate with `virsh destroy`, which ends the QEMU process at once. The definition and disk stay, so `virsh start` brings it back.
</details>

<details>
<summary>8. What is the difference between <code>virsh destroy</code> and <code>virsh undefine</code>?</summary>

`destroy` stops the running QEMU process; the definition and disk stay, and `virsh start` works again. `undefine` deletes the persistent definition; a running domain keeps running but becomes transient.
</details>

## Clean up the playground

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy libvirt-vm-lifecycle
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-032
```

Then run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean.

> *A domain is a blueprint plus a process: `define` files the blueprint, `start` launches the ship, `autostart` adds a link, `shutdown` asks, `destroy` forces, and only `undefine` deletes.*
