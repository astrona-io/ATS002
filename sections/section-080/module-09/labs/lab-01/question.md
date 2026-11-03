# Question

Solve this question on: `terminal`

This machine has two spare 1 GB disks with the serials `lab08a-suspect` and `lab08a-other`. The kernel log holds an I/O error about the suspect disk. The disk has data on it that must not change. Write the diagnosis report into the directory `/var/tmp/disk-report/`.

1. Find the suspect disk by its serial number. Do not assume device letters such as `/dev/vdb`.
2. Write the real device path of the suspect disk (for example `/dev/vdc`) into `/var/tmp/disk-report/device.txt`.
3. Write its exact size in bytes, only the number, into `/var/tmp/disk-report/size.txt`.
4. Save the output of `smartctl -H` for the suspect disk into `/var/tmp/disk-report/smart.txt`. Include the error output. The disk is virtual, so it may report that SMART is unavailable.
5. Save the kernel log lines that report an I/O error into `/var/tmp/disk-report/kernel-errors.txt`.
6. Scan the suspect disk for bad blocks in the **read-only** mode, and save the full output, including the final summary, into `/var/tmp/disk-report/badblocks.txt`.

The grader checks that:

- `device.txt` names the suspect disk and `size.txt` holds its exact size in bytes
- `smart.txt` holds the output of `smartctl`
- `kernel-errors.txt` holds the I/O error line about the suspect disk
- `badblocks.txt` holds the summary of a finished scan
- the data at the start of the suspect disk is unchanged
