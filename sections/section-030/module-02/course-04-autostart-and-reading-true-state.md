# Part 4 — Autostart and reading a domain's true state

> Prerequisite: [Part 3 — Persistent vs. transient: the domain lifecycle](./course-03-persistent-vs-transient-lifecycle.md). Next: [Part 5 — Graceful shutdown vs. hard power-off](./course-05-graceful-shutdown-vs-hard-destroy.md).

A defined, persistent domain still does not come up when the host boots — that is a separate switch. And once it is running, the flags you *think* you set are not evidence; the daemon's own report is. This part covers the two inspection habits that keep you honest: enabling autostart (and knowing where that setting is actually stored), and reading `virsh dominfo` correctly, units and all.

## Autostart is a separate step from defining

Concrete first:

```bash
# shell: host, root
sudo virsh autostart inventory-db
# Domain 'inventory-db' marked as autostarted

sudo virsh autostart --disable inventory-db
# Domain 'inventory-db' unmarked as autostarted
```

Defining a domain (Part 3) registers it. It does **not** arrange for it to start with the host. `virsh autostart` is the switch that does, and it is easy to forget precisely *because* it is separate — a task that says "the VM must come back automatically after a host reboot" is testing this command, not the define.

## Where autostart is stored: a symlink, not an XML field

This is the mechanism worth remembering. `virsh autostart` does not add anything to the domain XML. It creates a **symlink**:

```bash
sudo ls -l /etc/libvirt/qemu/autostart/
# lrwxrwxrwx 1 root root 32 ... inventory-db.xml -> /etc/libvirt/qemu/inventory-db.xml
```

```
  /etc/libvirt/qemu/
  ├── inventory-db.xml                 <- the domain definition (Part 1)
  └── autostart/
      └── inventory-db.xml  ─────────► ../inventory-db.xml   (symlink = "start me on boot")
```

On host boot, `libvirtd` / `virtqemud` starts every domain that has a link in `autostart/`. `--disable` deletes the link. The link's presence *is* the setting — there is no separate config value.

Two consequences fall straight out of that:

- **Autostart does not travel with the XML.** Copy `virsh dumpxml inventory-db` output to another host and `virsh define` it there, and the new host has the domain but no autostart link. You must re-run `virsh autostart` on the second host. Part 1 flagged this: the portable XML is not the whole story.
- **Undefining removes the link too.** `virsh undefine` cleans up the `autostart/` symlink along with the definition, so you never get a dangling link pointing at a deleted file.

> [!TIP]
> **Try it — the switch is one symlink.** On the host, with `inventory-db` defined from Part 2:
>
> ```sh
> sudo ls /etc/libvirt/qemu/autostart/ 2>/dev/null || echo "(no autostart dir yet)"
> sudo virsh autostart inventory-db
> sudo ls -l /etc/libvirt/qemu/autostart/
> sudo virsh autostart --disable inventory-db
> sudo ls /etc/libvirt/qemu/autostart/ 2>/dev/null || echo "(empty again)"
> ```
>
> Expect something like:
>
> ```text
> (no autostart dir yet)
> Domain 'inventory-db' marked as autostarted
> lrwxrwxrwx 1 root root 32 Sep  6 12:00 inventory-db.xml -> /etc/libvirt/qemu/inventory-db.xml
> Domain 'inventory-db' unmarked as autostarted
> (empty again)
> ```
>
> The `virsh autostart` verb did exactly one thing to the filesystem: create (then delete) that symlink. Re-enable it before the next checkpoint: `sudo virsh autostart inventory-db`.

## `virsh dominfo` is the authoritative state

Do not trust your memory of the `virt-install` flags. Ask the daemon:

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

Line by line, the ones tasks ask about:

- **`State`** — `running`, `shut off`, `paused`, `crashed`. The real current state, not what you expect.
- **`CPU(s)`** — the vCPU count. `2` here matches `--vcpus 2`.
- **`Persistent`** — `yes` / `no`. The Part 3 check: is there a file under `/etc/libvirt/qemu/`?
- **`Autostart`** — `enable` / `disable`. Whether the symlink above exists. (Yes, the word is `enable`, not `enabled`.)
- **`Max memory`** vs **`Used memory`** — see below.

```bash
virsh dominfo inventory-db | grep -i autostart
# Autostart:      enable
```

## Reading the memory lines correctly

Two traps in those two memory lines.

**Units change.** `virt-install --memory 2048` took MiB. `dominfo` reports **KiB**. 2048 MiB is `2048 × 1024 = 2097152 KiB`. If a task specifies "2048 MiB" and you are eyeballing `dominfo`, do the conversion before you conclude there is a mismatch — `2097152 KiB` *is* 2048 MiB, correctly allocated.

| You typed | Stored in XML | `dominfo` shows |
|---|---|---|
| `--memory 2048` (MiB) | `<memory unit='KiB'>2097152</memory>` | `Max memory: 2097152 KiB` |

**`Max memory` ≠ `Used memory`.** They answer different questions:

- **`Max memory`** — the domain's entitlement: the ceiling QEMU was started with (`<memory>` in the XML). This is what a task asking "was 2048 MiB allocated?" is checking.
- **`Used memory`** — the *current* allocation (`<currentMemory>`). With memory ballooning it can be dialled below `Max` while the guest runs; without ballooning configured the two simply match.

So "verify 2048 MiB was allocated" → check **`Max memory`**, and expect `2097152 KiB`.

> [!TIP]
> **Try it — read the domain's real state.** On the host:
>
> ```sh
> sudo virsh dominfo inventory-db
> ```
>
> Expect something like:
>
> ```text
> Id:             5
> Name:           inventory-db
> UUID:           7b9f...c2a1
> OS Type:        hvm
> State:          running
> CPU(s):         2
> Max memory:     2097152 KiB
> Used memory:    2097152 KiB
> Persistent:     yes
> Autostart:      enable
> Managed save:   no
> ```
>
> `Id` varies. `Max memory: 2097152 KiB` is the `--memory 2048` you passed in Part 2 — `2048 × 1024`, not a mismatch. `Persistent: yes` (Part 3) and `Autostart: enable` (from the checkpoint above) are both here because both have a file on disk backing them.
> - `Autostart: enable` reads oddly but is correct output — do not "fix" it.
> - A `dominfo` `Max memory` of `2097152 KiB` is **not** a bug when the task said 2048 MiB. Convert units first.
> - Do not report a memory mismatch based on `Used memory`. If it looks low, check whether it just reflects live ballooning; `Max memory` is the entitlement the task cares about.
> - `dominfo` is a snapshot. For a domain mid-`shutdown` (Part 5), run it again — `State` may still say `running` for a while.

> *Autostart is a symlink under `/etc/libvirt/qemu/autostart/`, not an XML field, so it does not travel with a domain; `virsh dominfo` is the real state, and its memory lines are in KiB with `Max memory` being the entitlement.*

## Reference

- `man virsh` — the `autostart` and `dominfo` entries; also `dumpxml`, `dommemstat` for the fuller memory picture.
- `https://libvirt.org/formatdomain.html#memory-allocation` — `<memory>` vs `<currentMemory>` and how ballooning connects them.
- `virsh dommemstat <name>` — live memory counters (actual, available, unused) when `dominfo`'s two lines are not enough.
