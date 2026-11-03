# Summary

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about reading a ship's gauges: finding the right disk, asking it about its health and testing it safely.

**From [Identify The Disk And Read Its Health](./course-01-identify-and-read-health.md):**

- `/dev/disk/by-id` links use serial numbers, so they name a disk safely. `readlink -f` turns a link into the real device.
- `lsblk -d -o NAME,SIZE,TYPE,SERIAL` lists disks, and `lsblk -bdno SIZE <disk>` prints the exact size in bytes.
- `smartctl -i`, `-H` and `-A` show identity, verdict and attributes. A virtual disk has no SMART data, and that is not proof of health.

**From [Kernel Log And Bad Blocks](./course-02-kernel-log-and-bad-blocks.md):**

- `dmesg` and `journalctl -k` show disk I/O errors. Filter them with `grep -i 'i/o error'`.
- `badblocks -sv <disk>` is the safe read-only scan. `-n` is non-destructive read-write, and `-w` destroys all data.
- Hash the start of the disk before and after to prove a scan changed nothing.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Disk Health Diagnosis Lab](./labs/lab-01/README.md) | Kernel Log And Bad Blocks | Found a disk by serial, recorded its size, SMART answer and kernel errors, and ran a read-only bad-block scan that left the data intact |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why look a disk up in <code>/dev/disk/by-id</code> instead of using <code>/dev/vdb</code>?</summary>

Device letters depend on the order the kernel finds disks and can change. The serial number in the by-id link always names the same disk.
</details>

<details>
<summary>2. <code>smartctl -H</code> reports no SMART data on a virtual disk. Is the disk healthy?</summary>

Unknown. There is nothing to read, so use the kernel log and a scan instead.
</details>

<details>
<summary>3. Which command shows disk I/O errors from the kernel?</summary>

`sudo dmesg | grep -i 'i/o error'`, or `journalctl -k` for the journal copy.
</details>

<details>
<summary>4. Which <code>badblocks</code> mode is safe on a disk with data you need?</summary>

The default read-only mode, `badblocks -sv <disk>`. The `-w` mode destroys all data.
</details>

## Clean up the playground

When you are done with this module, remove the playground and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy disk-health-bench
```

If `astrona list` also showed a mission, remove it the same way, for example:

```sh
astrona destroy ats-002-lab-08a
```

Run `astrona list` again to check that everything is gone. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
