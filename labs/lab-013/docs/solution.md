# Solution Walkthrough

Follow these steps to load, parameterize, and persist the `dummy` module, then blacklist and unload `pcspkr`.

---

## Step 1: Inspect what's currently loaded

```bash
lsmod | grep -E 'dummy|pcspkr'
```

`dummy` shouldn't appear yet. `pcspkr` should already be loaded (it's currently loaded and beeping, per the scenario).

---

## Step 2: Check the `dummy` module's parameters before loading it

```bash
modinfo -p dummy
```

Confirm `numdummies` is a real, correctly-spelled parameter before attempting to load with it.

---

## Step 3: Load `dummy` live with the parameter

```bash
sudo modprobe dummy numdummies=2
```

Verify it took:

```bash
lsmod | grep dummy
cat /sys/module/dummy/parameters/numdummies
```

---

## Step 4: Persist the `dummy` module's load across reboots

```bash
echo "dummy" | sudo tee /etc/modules-load.d/dummy.conf
```

---

## Step 5: Persist the `dummy` module's parameter across reboots

```bash
echo "options dummy numdummies=2" | sudo tee /etc/modprobe.d/dummy.conf
```

Prove the file — not the earlier interactive command — actually drives the value:

```bash
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies
# 2
```

---

## Step 6: Blacklist `pcspkr` so it never auto-loads again

```bash
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
```

---

## Step 7: Unload the already-loaded `pcspkr` and confirm the blacklist holds

```bash
sudo modprobe -r pcspkr
sudo udevadm trigger
lsmod | grep pcspkr
```

If `pcspkr` stays absent after `udevadm trigger` (which simulates a hardware re-detection pass without a reboot), the blacklist is working against the automatic path. An explicit `sudo modprobe pcspkr` would still load it — that's expected, documented behavior, not a bug.

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

---

## Command Summary

```bash
lsmod | grep -E 'dummy|pcspkr'
modinfo -p dummy

sudo modprobe dummy numdummies=2
echo "dummy" | sudo tee /etc/modules-load.d/dummy.conf
echo "options dummy numdummies=2" | sudo tee /etc/modprobe.d/dummy.conf
sudo modprobe -r dummy
sudo modprobe dummy
cat /sys/module/dummy/parameters/numdummies

echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/blacklist-pcspkr.conf
sudo modprobe -r pcspkr
sudo udevadm trigger
lsmod | grep pcspkr
```

Once verified, run the local validation suite to pass the lab!
