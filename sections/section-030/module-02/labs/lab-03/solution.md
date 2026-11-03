# Solution Walkthrough

Changing a domain's memory or number of virtual CPUs has a scope trap. With no scope flag, `virsh setmem` and `virsh setvcpus` use `--current`, which means the domain's current state. On a running domain that is only the **running** QEMU process, and the change is gone at the next full power-off. To make a change stick, you must write it into the **persistent XML**, either with `--config` on those commands or by editing the XML directly.

This domain is shut off, so there is no live instance to change anyway. The persistent configuration is the only thing to edit, and `--config` makes that target explicit.

Several commands below run `virsh` without `sudo`. As a normal user, `virsh` may connect to the private `qemu:///session` instance and not see `web-db`. If that happens, put `sudo` in front, or run `export LIBVIRT_DEFAULT_URI=qemu:///system` once in your shell first.

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

This output is shortened to the lines that matter, and the `(512 MiB)` note was added by hand.

```bash
virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'
```

```
<memory unit='KiB'>524288</memory>
<currentMemory unit='KiB'>524288</currentMemory>
<vcpu placement='static'>1</vcpu>
```

There are **two** memory elements. `<memory>` is the maximum. `<currentMemory>` is the amount actually given to the guest (the balloon target). Raising only `<memory>` leaves the guest capped at 512 MiB.

---

## Step 2a: The direct route with `virsh edit`

```bash
sudo virsh edit web-db
```

Change all three lines:

```xml
<memory unit='KiB'>2097152</memory>
<currentMemory unit='KiB'>2097152</currentMemory>
<vcpu placement='static'>2</vcpu>
```

`2097152 = 2048 * 1024`. Save and exit. `virsh` checks the XML and writes the persistent definition. The `<vcpu>` element has no `current='...'` attribute, so setting its text to `2` sets both the maximum and the active count to 2.

## Step 2b: The command route with `virsh set* --config`

This does the same without an editor. The order matters: raise the maximum first.

```bash
sudo virsh setvcpus  web-db 2       --config --maximum
sudo virsh setvcpus  web-db 2       --config
sudo virsh setmaxmem web-db 2048M   --config
sudo virsh setmem    web-db 2048M   --config
```

- `setvcpus --maximum` raises the ceiling. Without it, `setvcpus 2` is rejected, because 2 is more than the current maximum of 1.
- `setmaxmem` sets `<memory>` and `setmem` sets `<currentMemory>`. You need both, for the same reason as in Step 2a.
- `--config` means "write the persistent XML". On this shut-off domain the default `--current` would land there too, but on a running domain it would only change the live one. `--config` makes the change permanent in every case.

You only need one of the two routes. If you run `astrona submit -c sections/section-030/module-02/labs/lab-03` from your own computer now, the grader still fails: the domain is not running yet.

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

Confirm that the persistent configuration also holds the new values. This is what survives a reboot:

```bash
virsh dumpxml --inactive web-db | grep -E '<memory|<currentMemory|<vcpu'
```

```
<memory unit='KiB'>2097152</memory>
<currentMemory unit='KiB'>2097152</currentMemory>
<vcpu placement='static'>2</vcpu>
```

Run `astrona submit -c sections/section-030/module-02/labs/lab-03` again. Every check should pass now.

On a running domain, `virsh setmem web-db 2048M` on its own changes the running domain and nothing else. Reboot the host and the domain is back to 512 MiB. `--config` (or `virsh edit`) is the difference between "for now" and "for good".

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
