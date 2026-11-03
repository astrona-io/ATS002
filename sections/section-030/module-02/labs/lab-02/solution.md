# Solution Walkthrough

A domain started with `virsh create <file.xml>` runs at once, but it exists only in the memory of `libvirtd`. There is no file in `/etc/libvirt/qemu/`, so `virsh list --all` stops showing it the moment it powers off, and it does not come back after a host reboot. This walkthrough rescues it: it turns the running but fragile domain into a permanent one **without any outage**.

Several commands below run `virsh` without `sudo`. As a normal user, `virsh` may connect to the private `qemu:///session` instance and not see `metrics-cache`. If that happens, put `sudo` in front, or run `export LIBVIRT_DEFAULT_URI=qemu:///system` once in your shell first.

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

This output is shortened to the lines that matter. `Persistent: no` is the sign of a transient domain. There is also no definition on disk yet:

```bash
sudo ls /etc/libvirt/qemu/metrics-cache.xml
# ls: cannot access ...: No such file or directory
```

If you run `astrona submit -c sections/section-030/module-02/labs/lab-02` from your own computer now, the grader reports that the domain is still transient.

---

## Step 2: Make it persistent in place with `virsh define`

`virsh define` writes a persistent definition from an XML file. Run it on the **same XML the domain is already running from**. libvirt attaches that definition to the live domain instead of creating a second one:

```bash
sudo virsh define /root/metrics-cache.xml
```

```
Domain 'metrics-cache' defined from /root/metrics-cache.xml
```

The running QEMU process is never touched: no pause, no restart. Check again:

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

`create` means "run this XML now". `define` means "remember this XML". A transient domain is one that someone created but never defined.

---

## Step 3: Enable autostart

```bash
sudo virsh autostart metrics-cache
virsh dominfo metrics-cache | grep -i autostart
# Autostart:      enable
```

This creates a symlink at `/etc/libvirt/qemu/autostart/metrics-cache.xml` that points back at the definition, so `libvirtd` starts the domain when the host boots:

```bash
sudo ls -l /etc/libvirt/qemu/autostart/metrics-cache.xml
```

Run `astrona submit -c sections/section-030/module-02/labs/lab-02` again. Every check should pass now.

---

## Step 4: Prove it now survives a stop

Before the fix, stopping the domain would have erased it. Now:

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

A transient domain would have been **gone** from `virsh list --all` after `destroy`. You can leave it running or shut off; the grader accepts both. What matters is that the definition stays.

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
