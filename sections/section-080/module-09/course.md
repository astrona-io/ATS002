# Disk Health And Diagnosis

Astronaut, a ship does not wait for a bay to fail. It reads the gauges, listens to the alarms and tests a bay that behaves strangely before cargo is lost. On Linux, the gauges are `lsblk` and `smartctl`, the alarm log is the kernel log, and the test is `badblocks`.

In this module you learn to find the right disk, ask it about its health, read the I/O errors in the kernel log and scan it for bad blocks without destroying the data on it.

## Learning objectives

After this module you can:

- Find a disk by its serial number and read its size and type with `lsblk` and `/dev/disk/by-id`.
- Ask a disk about its health with `smartctl`, and explain what it means when a disk has no SMART data.
- Find I/O errors in the kernel log with `dmesg` and `journalctl -k`.
- Scan a disk for bad blocks with `badblocks` in its safe, read-only mode.
- Tell the safe scan modes from the destructive one.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to use a Linux shell and `sudo`.**
- **That a block device is a disk or a partition** and that its name, such as `/dev/vdb`, is not fixed.

### What is in your playground

Your playground is a training ship: one Ubuntu 24.04 virtual machine with two spare disks.

- Two spare 1 GB disks with the serials `lab08a-suspect` and `lab08a-other`. Find them at `/dev/disk/by-id/virtio-<serial>`.
- A kernel log that already holds an I/O error message about the suspect disk.
- `smartctl`, `badblocks`, `lsblk` and `dmesg`.
- Your own machine stays healthy and reachable; only the spare disks are scanned.

Start the playground, then open a terminal on it with `astrona ssh astro-disk-health-bench`. The hands-on steps in the parts build on each other on this one running ship. Every command block says which shell and which rights it expects.

<!-- astrona:playground -->

## How this module is laid out

1. [Identify The Disk And Read Its Health](./course-01-identify-and-read-health.md): `lsblk`, serial numbers and `smartctl`.
2. [Kernel Log And Bad Blocks](./course-02-kernel-log-and-bad-blocks.md): `dmesg`, `journalctl -k` and a safe `badblocks` scan.
   - Mission: Disk Health Diagnosis Lab
3. [Summary](./course-03-wrap-up.md)

## Why this matters

A failing disk usually warns first: a rising error count, a few I/O errors in the log, a slow bay. If you cannot find the right disk and read those signs, you replace the wrong one or find out only when the data is gone. The exam asks you to identify a disk and check it without harming what is on it.

<!-- curriculum-practice -->
## Practice and assessment

- [Disk Health Diagnosis Lab](labs/lab-01/question.md): Find a disk by serial and report its size, SMART answer and kernel I/O errors; Run a read-only bad-block scan that leaves the data intact.
- [System Disaster Recovery Integration Capstone Lab](../capstone/labs/lab-01/question.md): Restore a wiped GPT table from a backup and prove the filesystems are intact; Reinstall GRUB and regenerate grub.cfg on the running machine.
