# Solution Walkthrough

This capstone joins two skills: build a tool from source with an exact install path and one feature switched off, then define and start a libvirt domain for that tool to report on. After each half you can run `astrona submit -c sections/section-030/capstone/labs/lab-01` from your own computer and watch more checks turn green.

Several commands below run `virsh` without `sudo`. As a normal user, `virsh` may connect to the private `qemu:///session` instance and not see `build-agent`. If that happens, put `sudo` in front, or run `export LIBVIRT_DEFAULT_URI=qemu:///system` once in your shell first.

---

## Build and install `vmreport`

The first half is a source build: unpack, find the flags, configure, build, install, and check the result on the program itself.

### Step 1: Extract the source tarball

```bash
cd /tools
tar xzf vmreport-1.0.tar.gz
cd vmreport-1.0
```

This tarball is `.tar.gz`, not `.tar.bz2`, so `-z` (gzip) is the right flag, not `-j` (bzip2). Always check the extension instead of reusing the last flags you typed from habit.

The `/tools` folder belongs to root. If `tar` reports "Permission denied" because your user cannot write there, run the `tar` command with `sudo`, or unpack it into your home folder with `tar xzf /tools/vmreport-1.0.tar.gz -C ~` and `cd ~/vmreport-1.0`. The build works the same from either place.

### Step 2: Discover the available configure flags

```bash
./configure --help
```

```
--bindir=DIR            user executables [EPREFIX/bin]
--disable-color         disable ANSI color output (script-friendly)
--enable-color          enable ANSI color output (default)
```

This output is shortened to the three lines that matter. The full help text also lists `--prefix` and the section headings.

### Step 3: Run configure with both requirements

```bash
./configure --bindir=/usr/local/bin --disable-color
```

`--bindir=/usr/local/bin` sets the exact folder the task asks for, instead of trusting `--prefix` alone. `--disable-color` is the feature switch the monitoring pipeline needs turned off.

### Step 4: Build and install

```bash
make
sudo make install
```

`make` builds the program from the `Makefile` that `./configure` wrote. `sudo make install` copies it into `/usr/local/bin`, which belongs to root.

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

If you submit now, the check on the `vmreport` binary passes. The domain checks still fail.

---

## Define and start the `build-agent` domain

The second half is a libvirt lifecycle task: define the domain persistently, turn on autostart, and start it.

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

`--import` wraps libvirt management around the existing (empty) disk image instead of booting installation media. This host is itself a virtual machine, so hardware-accelerated KVM may be missing. `virt-install` then falls back to software emulation by itself, and the domain still reaches the `running` state.

### Step 3: Confirm persistence and configure autostart

```bash
virsh list --all
sudo ls /etc/libvirt/qemu/build-agent.xml
sudo virsh autostart build-agent
virsh dominfo build-agent | grep -i autostart
# Autostart:      enable
```

### Step 4: Confirm the domain's real resources and state

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

This output is shortened: the real report also has lines such as `UUID` and `OS Type`. 2048 MiB shows as `2097152 KiB` (2048 × 1024). Trust the units `dominfo` gives, not your assumption.

---

## Close the loop: run `vmreport` against the real domain

```bash
sudo vmreport build-agent
```

```
vmreport: domain 'build-agent' state=running
```

`vmreport` runs `virsh dominfo build-agent` itself and picks out the `State:` line. It runs with `sudo` so that `virsh` reaches the system instance, where `build-agent` lives. This is where both halves meet: a tool built from source, at the exact path required, now reports live on a domain you defined and started. If either half is wrong (the binary missing, misnamed or built with the wrong feature switch; the domain not defined, not started or on the wrong network), this last command fails or reports a state other than `running`.

Submit now. Every check should pass.

---

## A note on shutdown (for your own understanding)

The grader only needs the domain to end up `running`. Still, remember why `virsh shutdown` and `virsh destroy` are not the same, because a later maintenance task could ask you to bring `build-agent` down cleanly:

- `virsh shutdown build-agent` sends an ACPI power-button event into the guest and waits for it to cooperate. It is right for a guest with a real operating system that can catch the event and shut down cleanly.
- `virsh destroy build-agent` ends the QEMU process at once, with no cleanup. It is the only option that works on a hung guest, or on a guest with no operating system to answer `shutdown`, like this disk image.

If you try either one here, run `sudo virsh start build-agent` afterwards, because the grader checks that the domain is running.

## Command Summary

```bash
# Build and install vmreport
cd /tools
tar xzf vmreport-1.0.tar.gz
cd vmreport-1.0
./configure --help | grep -i bindir
./configure --help | grep -i color
./configure --bindir=/usr/local/bin --disable-color
make
sudo make install
vmreport -version

# Define and start build-agent
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

# Close the loop
sudo vmreport build-agent
```
