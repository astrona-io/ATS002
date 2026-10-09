# Autostart And Reading A Domain's True State

Astronaut, a ship with a registered blueprint still does not launch by itself when the hangar opens. That is a separate switch. And once a domain runs, the flags you *think* you set are not proof; the daemon's own report is. This part covers two habits that keep you honest: turning on autostart (and knowing where that setting really lives), and reading `virsh dominfo` correctly, units and all.

## Autostart is a separate step from defining

**Autostart** means "launch this ship whenever the hangar opens": libvirt starts the domain each time its daemon starts, which normally happens when the host boots.

<!-- astrona:playground:renew -->

Here is the switch, on and off:

```bash
# shell: host, root
sudo virsh autostart inventory-db
# Domain 'inventory-db' marked as autostarted

sudo virsh autostart --disable inventory-db
# Domain 'inventory-db' unmarked as autostarted
```

Defining a domain registers it. It does **not** make the domain start with the host. `virsh autostart` is the switch that does. It is easy to forget precisely *because* it is a separate step. A task that says "the virtual machine must come back by itself after a host reboot" is testing this command, not `define`.

## Where autostart is stored: a symlink, not an XML field

This is the mechanism worth remembering. `virsh autostart` adds nothing to the domain XML. It creates a **symlink** (symbolic link, a small file that points at another file).

### The link on disk

```bash
sudo ls -l /etc/libvirt/qemu/autostart/
# lrwxrwxrwx 1 root root 32 ... inventory-db.xml -> /etc/libvirt/qemu/inventory-db.xml
```

```
  /etc/libvirt/qemu/
  ├── inventory-db.xml                 <- the domain definition
  └── autostart/
      └── inventory-db.xml  ─────────► ../inventory-db.xml   (symlink = "start me on boot")
```

When the host boots, the libvirt daemon (`libvirtd` or `virtqemud`) starts every domain that has a link in `autostart/`. `--disable` deletes the link. The link being there *is* the setting; there is no other value stored anywhere.

### What follows from that

Two facts come straight out of this design:

- **Autostart does not travel with the XML.** Copy the `virsh dumpxml inventory-db` output to another host and `virsh define` it there, and the new host has the domain but no autostart link. You must run `virsh autostart` again on the second host. The portable XML is not the whole story.
- **Undefining removes the link too.** `virsh undefine` cleans up the `autostart/` symlink along with the definition, so you never get a broken link pointing at a deleted file.

### See it in your playground

Make sure `inventory-db` is defined on your playground host first (`sudo virsh list --all` shows it). Then watch the switch create and delete one symlink:

```sh
sudo ls /etc/libvirt/qemu/autostart/ 2>/dev/null || echo "(no autostart dir yet)"
sudo virsh autostart inventory-db
sudo ls -l /etc/libvirt/qemu/autostart/
sudo virsh autostart --disable inventory-db
sudo ls /etc/libvirt/qemu/autostart/ 2>/dev/null || echo "(empty again)"
```

Expect something like:

```text
(no autostart dir yet)
Domain 'inventory-db' marked as autostarted
lrwxrwxrwx 1 root root 32 Sep  6 12:00 inventory-db.xml -> /etc/libvirt/qemu/inventory-db.xml
Domain 'inventory-db' unmarked as autostarted
(empty again)
```

The `virsh autostart` command did exactly one thing to the file system: it created, and then deleted, that symlink. Turn it on again before the next step: `sudo virsh autostart inventory-db`.

## `virsh dominfo` is the authoritative state

Do not trust your memory of the `virt-install` flags. Ask the daemon. `virsh dominfo` prints the domain's real state as libvirt sees it right now.

### The report

```bash
# shell: host, unprivileged is fine
virsh dominfo inventory-db
```

```
Id:             3
Name:           inventory-db
UUID:           a1b2c3d4-...-9f0
OS Type:        hvm
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      enable
Managed save:   no
```

The comment says "unprivileged is fine", but as a normal user `virsh` may connect to the private `qemu:///session` hangar and not find the domain. Use `sudo virsh dominfo` or export `LIBVIRT_DEFAULT_URI=qemu:///system` first.

### The lines tasks ask about

Read the report line by line:

- **`State`**: `running`, `shut off`, `paused` or `crashed`. The real current state, not the one you expect.
- **`CPU(s)`**: the number of virtual CPUs. `2` here matches `--vcpus 2`.
- **`Persistent`**: `yes` or `no`. Is there a definition file under `/etc/libvirt/qemu/`?
- **`Autostart`**: `enable` or `disable`. Whether the symlink above exists. (Yes, the word is `enable`, not `enabled`.)
- **`Max memory`** and **`Used memory`**: see below.

To check one line only, filter it:

```bash
virsh dominfo inventory-db | grep -i autostart
# Autostart:      enable
```

## Reading the memory lines correctly

The two memory lines hold two traps. Both make a correct domain look wrong.

### Units change

`virt-install --memory 2048` took MiB. `dominfo` reports **KiB**. 2048 MiB is `2048 × 1024 = 2097152 KiB`. If a task says "2048 MiB" and you read `dominfo`, convert before you decide there is a mismatch. `2097152 KiB` *is* 2048 MiB, correctly allocated.

| You typed | Stored in XML | `dominfo` shows |
|---|---|---|
| `--memory 2048` (MiB) | `<memory unit='KiB'>2097152</memory>` | `Max memory: 2097152 KiB` |

### `Max memory` is not `Used memory`

The two lines answer different questions:

- **`Max memory`** is the domain's entitlement: the ceiling QEMU was started with (`<memory>` in the XML). A task that asks "was 2048 MiB allocated?" is checking this.
- **`Used memory`** is the *current* allocation (`<currentMemory>` in the XML). With **memory ballooning** (a driver in the guest that can hand memory back to the host), it can be set below `Max` while the guest runs. Without ballooning set up, the two simply match.

So for "verify that 2048 MiB was allocated", check **`Max memory`** and expect `2097152 KiB`. If you raise a domain's memory, raise both `<memory>` and `<currentMemory>`; raising only the maximum leaves the guest capped at the old current value.

### See it in your playground

Read the domain's real state on the host:

```sh
sudo virsh dominfo inventory-db
```

Expect something like:

```text
Id:             5
Name:           inventory-db
UUID:           7b9f...c2a1
OS Type:        hvm
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      enable
Managed save:   no
```

The `Id` will be different. `Max memory: 2097152 KiB` is the `--memory 2048` you passed to `virt-install`: `2048 × 1024`, not a mismatch. `Persistent: yes` and `Autostart: enable` are both here because each one has a file on disk behind it.

## Common pitfalls

> [!WARNING]
> - **Forgetting `virsh autostart`.** A defined domain does *not* come up on host boot by itself.
> - **Expecting autostart to be in the XML.** It is a symlink under `/etc/libvirt/qemu/autostart/`; copying the `dumpxml` output to another host does not carry it.
> - **"Fixing" `Autostart: enable`.** It reads oddly but is the correct output.
> - **Calling `Max memory: 2097152 KiB` a bug** when the task said 2048 MiB. Convert units first.
> - **Reporting a memory mismatch based on `Used memory`.** If it looks low, check whether it just reflects live ballooning; `Max memory` is the entitlement the task cares about.
> - **Trusting one `dominfo` snapshot.** For a domain in the middle of a `shutdown`, run it again: `State` may still say `running` for a while.

> *Autostart is a symlink under `/etc/libvirt/qemu/autostart/`, not an XML field, so it does not travel with a domain. `virsh dominfo` shows the real state, and its memory lines are in KiB, with `Max memory` being the entitlement.*

## Your mission: Transient to Persistent Domain Lab

You can now tell a persistent domain from a transient one, prove which one you have, and make a domain start with the host. The mission gives you a running transient domain and asks you to make it persistent without stopping it, and to set it to autostart.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy libvirt-vm-lifecycle
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-02
astrona ssh ats-002-lab-033
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-02
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-033
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/playground
```

## Your mission: Reconfigure a Persistent Domain Lab

You can now read a domain's real memory and CPU values and tell the stored definition from the running one. The mission gives you a persistent domain that is too small and asks you to give it more memory and CPUs in its stored definition, so the change survives a reboot.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy libvirt-vm-lifecycle
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/labs/lab-03
astrona ssh ats-002-lab-034
```

Read the task in [`question.md`](./labs/lab-03/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-03
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-034
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/playground
```
