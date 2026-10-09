# Solution Walkthrough

This walkthrough defines a persistent domain around an existing disk image, turns on autostart, and shows the difference between a graceful shutdown and a hard power-off. After the steps that change the machine, you can run `astrona submit` from your own computer to see how far the grader agrees.

Several commands below run `virsh` without `sudo`. As a normal user, `virsh` may connect to the private `qemu:///session` instance and not see `inventory-db` at all. If that happens, put `sudo` in front, or run `export LIBVIRT_DEFAULT_URI=qemu:///system` once in your shell first.

---

## Step 1: Confirm libvirtd is running and the disk image is in place

```bash
sudo systemctl status libvirtd
ls -lh /var/lib/libvirt/images/inventory-db.qcow2
```

`virsh` talks to the `libvirtd` daemon over a local socket. If the daemon is not running, every `virsh` and `virt-install` command fails to connect before it even reaches the domain.

---

## Step 2: Define the domain around the existing disk image

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

`--import` tells `virt-install` to skip installation media and treat `--disk` as a disk that can already boot. That is the right tool for wrapping libvirt around an existing image instead of installing a new operating system. `--network network=default` connects the domain to libvirt's built-in NAT network. `--graphics none --noautoconsole` keep it without a screen and give you your prompt back at once.

This disk image has no operating system on it, and that is expected in this lab. `virt-install` still defines the domain and starts the QEMU process. libvirt reports the domain as `running` whether or not an operating system boots inside, because the domain's state is about the QEMU process, not about what happens in the guest.

This host is itself a virtual machine, so hardware acceleration through `/dev/kvm` may be missing. `virt-install` then falls back to software emulation (TCG) by itself. You need no extra flag, and the lifecycle steps (defined, running, shut off) work the same, only slower.

---

## Step 3: Confirm the domain definition is persistent

```bash
virsh list --all
```

```
 Id   Name           State
--------------------------------
 1    inventory-db   running
```

`virt-install` defines domains persistently by default, so `inventory-db` stays in `virsh list --all` even after it is shut off. Confirm that the XML was really written to the persistent store:

```bash
sudo ls /etc/libvirt/qemu/inventory-db.xml
```

---

## Step 4: Configure autostart

```bash
sudo virsh autostart inventory-db
```

This marks the domain to start whenever `libvirtd` starts, which normally happens at host boot. libvirt does it by creating a symlink under `/etc/libvirt/qemu/autostart/` that points back at the domain's XML. Verify:

```bash
virsh dominfo inventory-db | grep -i autostart
# Autostart:      enable
```

Now run `astrona submit -c sections/section-030/module-02/labs/lab-01` from your own computer. Every check should pass.

---

## Step 5: Confirm it's running and check the real resources

```bash
virsh dominfo inventory-db
```

```
Id:             1
Name:           inventory-db
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      enable
```

This output is shortened: the real report also has lines such as `UUID` and `OS Type`. `dominfo` is the trusted source for the domain's real settings. 2048 MiB shows up as `2097152 KiB` (2048 × 1024).

---

## Step 6: Graceful shutdown vs. hard power-off

```bash
virsh shutdown inventory-db
```

This sends an ACPI power-button event into the guest and asks its operating system to run a clean shutdown. Watch the state:

```bash
watch -n1 virsh list --all
```

This disk has no operating system to catch the ACPI event, so the domain will most likely **never** reach `shut off` by itself. It stays `running`. That is the lesson: `shutdown` is a *request*, not a guarantee, and a guest with no ACPI handling (or, as here, no operating system at all) never acts on it. Press `Ctrl+C` to leave `watch`.

Escalate to a hard power-off:

```bash
virsh destroy inventory-db
```

`destroy` does not delete the domain's definition or its disk image. The libvirt daemon ends the QEMU process at once, the software version of pulling the power cord. Unlike `shutdown`, the domain is `shut off` immediately, because nothing inside the guest has to cooperate.

**The difference:** `shutdown` asks the guest to clean up first (write cached data to disk, unmount filesystems, stop services) and then power off. Use it when the guest responds and you can wait. `destroy` is a hard stop with no cleanup. Use it when the guest is hung, does not respond, or, as here, has no operating system to respond. Both leave the domain in the same `shut off` state, but only `shutdown` gives the guest a chance to stop cleanly.

```bash
virsh start inventory-db
```

Because the domain is persistently defined, `virsh start` works after either kind of stop.

---

## Verification

```bash
virsh list --all
virsh dominfo inventory-db
# CPU(s): 2, Max memory: 2097152 KiB (2048 MiB), Persistent: yes, Autostart: enable

ls /etc/libvirt/qemu/autostart/inventory-db.xml
# symlink confirms autostart registration

virsh dumpxml inventory-db | grep "network='default'"
# confirms default network attachment

virsh shutdown inventory-db && sleep 5 && virsh list --all
# State likely stays "running" -- no guest OS to catch the ACPI signal

virsh destroy inventory-db
virsh list --all
# immediately "shut off" -- no grace period, unlike shutdown
```

The grader does not mind whether the domain ends up running or shut off. It checks the definition, the size, the network and autostart.

## Command Summary

```bash
sudo systemctl status libvirtd
ls -lh /var/lib/libvirt/images/inventory-db.qcow2
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
virsh list --all
sudo virsh autostart inventory-db
virsh dominfo inventory-db
virsh shutdown inventory-db
virsh destroy inventory-db
virsh start inventory-db
```
