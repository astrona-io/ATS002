# Solution Walkthrough

This walkthrough finds the suspect disk by its serial, collects the diagnosis files and runs a safe read-only scan.

The commands use a shell variable, so you never have to guess which device letter the disk got. The path `/dev/disk/by-id/virtio-lab08a-suspect` always points at the right disk.

---

## Step 1: Find the suspect disk

```bash
SUSPECT=$(readlink -f /dev/disk/by-id/virtio-lab08a-suspect)
echo "$SUSPECT"
lsblk -d -o NAME,SIZE,TYPE,SERIAL
```

The serial column shows which disk is which.

---

## Step 2: Write the device and the size

```bash
echo "$SUSPECT" > /var/tmp/disk-report/device.txt
lsblk -bdno SIZE "$SUSPECT" > /var/tmp/disk-report/size.txt
cat /var/tmp/disk-report/size.txt
```

The size is the number of bytes, for a 1 GB disk `1073741824`.

---

## Step 3: Ask for the health

```bash
sudo smartctl -H "$SUSPECT" 2>&1 | tee /var/tmp/disk-report/smart.txt
```

A virtual disk reports that it cannot give SMART data. The file still holds the `smartctl` output, which is what the report needs.

---

## Step 4: Save the kernel errors

```bash
sudo dmesg | grep -i 'i/o error' | tee /var/tmp/disk-report/kernel-errors.txt
```

The line names the suspect disk and a sector number.

---

## Step 5: Scan safely

```bash
sudo badblocks -sv "$SUSPECT" 2>&1 | tee /var/tmp/disk-report/badblocks.txt
```

This is the default read-only mode, so the data is not touched. The scan ends with `Pass completed, 0 bad blocks found. (0/0/0 errors)`. Do not use `-w`: it overwrites the disk and the grader will see the data gone.

---

## Submit

```bash
astrona submit -c sections/section-080/module-09/labs/lab-01
```
