# Solution Guide: Reconfigure a Persistent Domain

Changing a domain's memory or vCPU count has a scope trap. `virsh setmem`
and `virsh setvcpus` default to `--live` (or `--current`), which touches
only the **running** QEMU process — the change is gone on the next full
power-off. To make it stick you must write it into the **persistent XML**,
either with `--config` on those commands or by editing the XML directly.

This domain is shut off, so there is no live instance to change anyway —
the persistent config is the only thing to edit.

---

## Step 1: See the current (wrong) spec

```bash
virsh dominfo web-db
```

```
State:          shut off
CPU(s):         1
Max memory:     524288 KiB      (512 MiB)
Persistent:     yes
```

```bash
virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'
```

```
<memory unit='KiB'>524288</memory>
<currentMemory unit='KiB'>524288</currentMemory>
<vcpu placement='static'>1</vcpu>
```

Note there are **two** memory elements. `<memory>` is the maximum;
`<currentMemory>` is the amount actually given to the guest (the balloon
target). Raising only `<memory>` leaves the guest still capped at 512 MiB.

---

## Step 2a: The direct route — `virsh edit`

```bash
sudo virsh edit web-db
```

Change all three lines:

```xml
<memory unit='KiB'>2097152</memory>
<currentMemory unit='KiB'>2097152</currentMemory>
<vcpu placement='static'>2</vcpu>
```

`2097152 = 2048 * 1024`. Save and exit; `virsh` validates and writes the
persistent definition. Because the `<vcpu>` element has no `current='...'`
attribute, setting its text to `2` sets both the maximum and the active
count to 2.

## Step 2b: The command route — `virsh set* --config`

Equivalent, without an editor. Order matters: raise the maximum first.

```bash
sudo virsh setvcpus  web-db 2       --config --maximum
sudo virsh setvcpus  web-db 2       --config
sudo virsh setmaxmem web-db 2048M   --config
sudo virsh setmem    web-db 2048M   --config
```

- `setvcpus --maximum` raises the ceiling; without it, `setvcpus 2` is
  rejected because 2 exceeds the current max of 1.
- `setmaxmem` sets `<memory>`; `setmem` sets `<currentMemory>`. You need
  both, for the same reason as in Step 2a.
- `--config` = write the persistent XML. Leave it off and you would be
  trying to resize a domain that is not even running.

---

## Step 3: Start it and verify

```bash
sudo virsh start web-db
virsh dominfo web-db
```

```
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
```

Confirm the persistent config also holds the new values (this is what
survives a reboot):

```bash
virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'
```

```
<memory unit='KiB'>2097152</memory>
<currentMemory unit='KiB'>2097152</currentMemory>
<vcpu placement='static'>2</vcpu>
```

> `virsh setmem web-db 2048M` on its own changes the running domain and
> nothing else. Reboot the host and the domain is back to 512 MiB. `--config`
> (or `virsh edit`) is the difference between "for now" and "for good".

---

## Verification

```bash
virsh dominfo web-db
# State: running, CPU(s): 2, Max memory: 2097152 KiB, Persistent: yes

virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'
# all show the 2097152 / 2 values -- persisted, not live-only

virsh dumpxml --inactive web-db | grep -E "network='default'|web-db.qcow2"
# disk and network unchanged
```

## Command Summary

```bash
virsh dominfo web-db
virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'

# route A
sudo virsh edit web-db      # set <memory>, <currentMemory> to 2097152; <vcpu> to 2

# route B
sudo virsh setvcpus  web-db 2     --config --maximum
sudo virsh setvcpus  web-db 2     --config
sudo virsh setmaxmem web-db 2048M --config
sudo virsh setmem    web-db 2048M --config

sudo virsh start web-db
virsh dominfo web-db
```
