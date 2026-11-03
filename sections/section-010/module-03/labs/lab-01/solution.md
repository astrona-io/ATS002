# Solution Walkthrough

This walkthrough first loads the `dummy` module with its parameter and makes both survive a reboot. Then it blacklists `pcspkr`, unloads it, and proves the blacklist holds. You can run `astrona submit` after any step: each failing check names the one thing still missing.

---

## Step 1: Inspect what is loaded now

```bash
lsmod | grep -E 'dummy|pcspkr'
```

`dummy` should not appear yet. `pcspkr` should already be loaded: the lab's start-up script loaded it, to stand in for the beeping driver in the story.

---

## Step 2: Check the `dummy` module's parameters before loading it

```bash
modinfo -p dummy
```

Confirm that `numdummies` is a real parameter, spelled exactly like this, before you load the module with it. `modprobe` may ignore a misspelled parameter without any error.

---

## Step 3: Load `dummy` now with the parameter

```bash
sudo modprobe dummy numdummies=2
```

Check that it worked:

```bash
lsmod | grep dummy
cat /sys/module/dummy/parameters/numdummies
```

The kernel publishes the live value in `/sys/module/dummy/parameters/numdummies`. It should show `2`. This load is not kept: after a reboot, the module and its parameter would be gone.

---

## Step 4: Load `dummy` at every boot

Save this as `/etc/modules-load.d/dummy.conf`:

```ini
dummy
```

`systemd-modules-load.service` reads this file at every boot and loads each module name in it. Nothing needs to run now. This file holds bare names only, never parameters.

---

## Step 5: Keep the parameter for every load

Save this as `/etc/modprobe.d/dummy.conf`:

```ini
options dummy numdummies=2
```

Apply it by unloading the module and loading it again with a bare `modprobe`. This proves that the file, and not the command you typed in Step 3, sets the value:

```bash
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies
# 2
```

`modprobe` read the `options` line from `/etc/modprobe.d/dummy.conf` and passed `numdummies=2` to the kernel, even though you did not type it.

---

## Step 6: Blacklist `pcspkr` so it never loads automatically again

Save this as `/etc/modprobe.d/blacklist-pcspkr.conf`:

```ini
blacklist pcspkr
```

`modprobe` reads this line on every load. It tells `modprobe` to skip `pcspkr` when udev asks for it during hardware detection. An explicit `sudo modprobe pcspkr` would still load it, which is expected behaviour.

---

## Step 7: Unload `pcspkr` and confirm the blacklist holds

The blacklist only affects future loads, so unload the running module once by hand. Then replay hardware detection and check that it stays away:

```bash
sudo modprobe -r pcspkr
sudo udevadm trigger
lsmod | grep pcspkr
```

`udevadm trigger` makes the kernel send its device events again for hardware that is already present, which is the same thing that happens at boot. If `pcspkr` stays absent afterwards, the blacklist holds against the automatic path.

---

## Verification

```bash
lsmod | grep dummy
# dummy   ...   0

cat /sys/module/dummy/parameters/numdummies
# 2

cat /etc/modules-load.d/dummy.conf
# dummy

cat /etc/modprobe.d/dummy.conf
# options dummy numdummies=2

lsmod | grep pcspkr
# (no output)

cat /etc/modprobe.d/blacklist-pcspkr.conf
# blacklist pcspkr
```

Then send the mission for grading:

```bash
astrona submit -c sections/section-010/module-03/labs/lab-01
```

---

## Command Summary

The three configuration files:

| File | Content |
| --- | --- |
| `/etc/modules-load.d/dummy.conf` | `dummy` |
| `/etc/modprobe.d/dummy.conf` | `options dummy numdummies=2` |
| `/etc/modprobe.d/blacklist-pcspkr.conf` | `blacklist pcspkr` |

The commands:

```bash
lsmod | grep -E 'dummy|pcspkr'
modinfo -p dummy

sudo modprobe dummy numdummies=2
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies

sudo modprobe -r pcspkr
sudo udevadm trigger
lsmod | grep pcspkr
```
