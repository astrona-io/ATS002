# Solution Guide: New Toolchain, New Host

This capstone connects both halves of Section 030: build a tool from source with an exact install path and a disabled feature, then define and start a libvirt domain for that tool to report on.

---

## Part 1: Compile and Install `vmreport`

### Step 1: Extract the source tarball

```bash
cd /tools
tar xzf vmreport-1.0.tar.gz
cd vmreport-1.0
```

This tarball is `.tar.gz`, not `.tar.bz2` — `-z` selects gzip decompression, not `-j` (which is for bzip2). Always check the extension rather than reusing the last flag combination you typed from muscle memory.

### Step 2: Discover the available configure flags

```bash
./configure --help
```

```
--bindir=DIR            user executables [EPREFIX/bin]
--disable-color         disable ANSI color output (script-friendly)
--enable-color          enable ANSI color output (default)
```

### Step 3: Run configure with both requirements

```bash
./configure --bindir=/usr/local/bin --disable-color
```

`--bindir=/usr/local/bin` pins the exact directory the task requires, rather than trusting `--prefix` alone. `--disable-color` is the feature flag this headless monitoring pipeline needs turned off.

### Step 4: Build and install

```bash
make
sudo make install
```

### Step 5: Verify

```bash
which vmreport
# /usr/local/bin/vmreport

file /usr/local/bin/vmreport
# /usr/local/bin/vmreport: ELF 64-bit LSB executable, ...

vmreport -version
# vmreport 1.0 (compiled from source)
# Features: color=disabled
```

---

## Part 2: Define and Start the `build-agent` Domain

### Step 1: Confirm libvirtd is running and the disk image is staged

```bash
sudo systemctl status libvirtd
ls -lh /var/lib/libvirt/images/build-agent.qcow2
```

### Step 2: Define the domain around the existing disk image

```bash
sudo virt-install \
  --name build-agent \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/build-agent.qcow2,format=qcow2 \
  --import \
  --network network=default \
  --os-variant detect=on,require=off \
  --graphics none \
  --noautoconsole
```

`--import` wraps libvirt management around the existing (empty) disk image rather than trying to boot install media. This host may not have hardware-accelerated KVM available, since it's itself a virtualized guest — `virt-install` falls back to software emulation automatically in that case, and the domain still reaches a `running` state.

### Step 3: Confirm persistence and configure autostart

```bash
virsh list --all
sudo ls /etc/libvirt/qemu/build-agent.xml
sudo virsh autostart build-agent
virsh dominfo build-agent | grep -i autostart
# Autostart:      enable
```

### Step 4: Confirm the domain's actual resources and state

```bash
virsh dominfo build-agent
```

```
Id:             1
Name:           build-agent
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    2097152 KiB
Persistent:     yes
Autostart:      enable
```

2048 MiB reports as `2097152 KiB` (2048 × 1024) — trust `dominfo`'s own units over assumption.

---

## Part 3: Close the Loop — Run `vmreport` Against the Real Domain

```bash
sudo vmreport build-agent
```

```
vmreport: domain 'build-agent' state=running
```

`vmreport` shells out to `virsh dominfo build-agent` internally and extracts the `State:` line — this is the payoff of Part 1 and Part 2 landing correctly together: a tool built from source, at the exact path required, now reporting live on a domain defined and started with `virsh`/`virt-install`. If either half of this capstone is wrong — the binary missing, misnamed, or built with the wrong feature toggle; the domain not defined, not started, or attached to the wrong network — this final command either fails outright or reports a state other than `running`.

---

## A Note on Shutdown Semantics (For Your Own Understanding)

Although this capstone's grading only requires the domain to end up `running`, it's worth remembering why `virsh shutdown` and `virsh destroy` are not interchangeable, since a follow-up maintenance task could easily ask you to bring `build-agent` back down cleanly:

- `virsh shutdown build-agent` sends an ACPI power-button event into the guest and waits for it to cooperate — appropriate for a guest with a real OS installed that can catch the signal and shut down cleanly.
- `virsh destroy build-agent` immediately halts the underlying QEMU process with no cleanup opportunity — the only option that works against a hung guest, or (as with this disk image) a guest with no OS installed to respond to `shutdown` in the first place.

## Command Summary

```bash
# Part 1: compile and install vmreport
cd /tools
tar xzf vmreport-1.0.tar.gz
cd vmreport-1.0
./configure --help | grep -i bindir
./configure --help | grep -i color
./configure --bindir=/usr/local/bin --disable-color
make
sudo make install
vmreport -version

# Part 2: define and start build-agent
sudo virt-install \
  --name build-agent \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/build-agent.qcow2,format=qcow2 \
  --import \
  --network network=default \
  --os-variant detect=on,require=off \
  --graphics none \
  --noautoconsole
sudo virsh autostart build-agent
virsh dominfo build-agent

# Part 3: close the loop
sudo vmreport build-agent
```
