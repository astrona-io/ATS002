# Solution Guide: Promote a Transient Domain to Persistent

A domain started with `virsh create <file.xml>` runs immediately but exists
only in `libvirtd`'s memory. There is no file in `/etc/libvirt/qemu/`, so
`virsh list --all` will stop showing it the moment it powers off, and it
does not come back after a host reboot. This lab is the recovery: turn that
running-but-fragile domain into a permanent one **without an outage**.

---

## Step 1: Confirm what you are dealing with

```bash
virsh list --all
virsh dominfo metrics-cache
```

```
Id:             1
Name:           metrics-cache
State:          running
CPU(s):         1
Max memory:     1048576 KiB
Used memory:    1048576 KiB
Persistent:     no          <-- the problem
Autostart:      disable
```

`Persistent: no` is the signature of a transient domain. Also note there is
no definition on disk yet:

```bash
sudo ls /etc/libvirt/qemu/metrics-cache.xml
# ls: cannot access ...: No such file or directory
```

---

## Step 2: Promote it in place with `virsh define`

`virsh define` writes a persistent definition from an XML file. Run it
against the **same XML the domain is already running from** — libvirt
attaches that definition to the live domain instead of creating a second
one:

```bash
sudo virsh define /root/metrics-cache.xml
```

```
Domain 'metrics-cache' defined from /root/metrics-cache.xml
```

The running QEMU process is never touched — no pause, no restart. Re-check:

```bash
virsh dominfo metrics-cache
```

```
State:          running
Persistent:     yes         <-- fixed, and it never stopped
Autostart:      disable
```

```bash
sudo ls /etc/libvirt/qemu/metrics-cache.xml
# /etc/libvirt/qemu/metrics-cache.xml    <-- now on disk
```

> `create` = "run this XML now". `define` = "remember this XML". A transient
> domain is one someone `create`d but never `define`d.

---

## Step 3: Enable autostart

```bash
sudo virsh autostart metrics-cache
virsh dominfo metrics-cache | grep -i autostart
# Autostart:      enable
```

This drops a symlink at `/etc/libvirt/qemu/autostart/metrics-cache.xml`
pointing back at the definition, so `libvirtd` starts the domain on host
boot:

```bash
sudo ls -l /etc/libvirt/qemu/autostart/metrics-cache.xml
```

---

## Step 4: Prove it now survives a stop

Before the fix, stopping the domain would erase it. Now:

```bash
virsh destroy metrics-cache      # hard stop
virsh list --all
```

```
 Id   Name            State
----------------------------------
 -    metrics-cache   shut off    <-- still here, just off
```

```bash
virsh start metrics-cache        # and it starts straight back up
```

A transient domain would have been **gone** from `virsh list --all` after
`destroy`. Leave it either running or shut off — both are fine; the point is
the definition persists.

---

## Verification

```bash
virsh dominfo metrics-cache
# Persistent: yes, Autostart: enable, CPU(s): 1, Max memory: 1048576 KiB

sudo ls /etc/libvirt/qemu/metrics-cache.xml
sudo ls /etc/libvirt/qemu/autostart/metrics-cache.xml

virsh dumpxml --inactive metrics-cache | grep -E "network='default'|metrics-cache.qcow2"
# original network + disk still in the persistent definition
```

## Command Summary

```bash
virsh list --all
virsh dominfo metrics-cache
sudo virsh define /root/metrics-cache.xml
sudo virsh autostart metrics-cache
virsh dominfo metrics-cache
virsh destroy metrics-cache
virsh list --all
virsh start metrics-cache
```
