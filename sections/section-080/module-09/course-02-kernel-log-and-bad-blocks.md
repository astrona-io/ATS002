# Kernel Log And Bad Blocks

Astronaut, when a bay misbehaves, the ship's alarm log tells you first. This part reads the kernel log for disk errors and then tests the disk with a scan that does not harm its data.

## Read the kernel log

The kernel writes every hardware problem to its ring buffer. `dmesg` prints it. A failing disk shows lines with `I/O error`, `blk_update_request` or `Buffer I/O error`, followed by the device name and a sector number.

<!-- astrona:playground:renew -->

```bash
# shell: playground, root rights through sudo
sudo dmesg | grep -i 'i/o error'
```

Two options make the log easier to read. `dmesg -T` shows human clock times, and `dmesg --level=err,crit` keeps only the serious lines. On a system with the journal, `journalctl -k` shows the same kernel messages and keeps them after a reboot, and `journalctl -k -p err` filters by priority.

To keep the evidence, send the matching lines to a file:

```bash
mkdir -p /var/tmp/health-demo
sudo dmesg | grep -i 'i/o error' | tee /var/tmp/health-demo/errors.txt
```

The sector number in the message points at where the trouble is. Several errors on one device is a reason to scan it.

## Scan for bad blocks

`badblocks` reads, and optionally writes, every block of a disk and lists the ones that fail. It has three modes, and the difference matters:

| Mode | Command | Effect on the data |
| --- | --- | --- |
| Read-only (default) | `badblocks -sv DISK` | Only reads. Safe on a disk with data. |
| Non-destructive read-write | `badblocks -nsv DISK` | Writes and restores each block. Slow, and only safe on a disk that is not mounted. |
| Destructive write | `badblocks -wsv DISK` | Overwrites everything. **Destroys all data.** |

Always start with the read-only mode on a disk you care about. `-s` shows progress and `-v` prints a summary:

```bash
SUSPECT=$(readlink -f /dev/disk/by-id/virtio-lab08a-suspect)
sudo badblocks -sv "$SUSPECT" 2>&1 | tee /var/tmp/health-demo/badblocks.txt
```

A clean disk ends with `Pass completed, 0 bad blocks found. (0/0/0 errors)`. Any other number lists block numbers you can pass to a filesystem check or use to decide to replace the disk. Do not run `badblocks` on a mounted filesystem: the result is unreliable.

## Prove the scan did not hurt

A read-only scan leaves the disk exactly as it was. You can check that for yourself by hashing the start of the disk before and after:

```bash
head -c 1048576 "$SUSPECT" | sha256sum
```

The two hashes must be the same.

## Your mission

You now know how to find a disk, read its health, read the kernel log and scan it safely. Put it together in a graded mission.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy disk-health-bench
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-09/labs/lab-01
astrona ssh ats-002-lab-08a
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-080/module-09/labs/lab-01
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-08a
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-09/playground
```

## Common pitfalls

- Running `badblocks -w` on a disk with data. It destroys everything on it.
- Scanning a mounted filesystem.
- Reading only the last lines of `dmesg`. The ring buffer is long; filter it with `grep` instead.
