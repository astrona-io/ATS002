# Question

Solve this question on: `terminal`

This machine has three spare 1 GB disks with the serials `lab089-raid-a`, `lab089-raid-b` and `lab089-raid-c`. A RAID 1 array `/dev/md/cargo` was built from `a` and `b`, with an ext4 filesystem holding `marker.txt` and `logs/flight.log`. Disk `b` has failed and was removed, so the array is degraded. Disk `c` is blank. The files must not be lost.

1. Find the three disks. They are **not** the disk mounted as `/`. Do not assume device letters such as `/dev/vdb`.
2. Confirm the array is degraded, using `/proc/mdstat` and `mdadm --detail`.
3. Add disk `c` to the array as the replacement for `b`.
4. Wait for the rebuild to finish, so the array is `clean` with two active devices.
5. Save the array in `/etc/mdadm/mdadm.conf` with an `ARRAY` line, so it is assembled again after a reboot.
6. Mount the array, confirm both files are there, and unmount it when you are done.

The grader checks that:

- `/dev/md/cargo` is clean, with two active devices and no failed devices
- disk `c` is an active member of the array and disk `b` is not
- `/etc/mdadm/mdadm.conf` has an `ARRAY` line with the array's UUID
- the array mounts and `marker.txt` and `logs/flight.log` still have their original content
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-08](../../course.md).

The grader checks:

- Confirms /dev/md/cargo is clean with two active devices and no failed devices.
- Confirms disk c is an active member and failed disk b is not.
- Confirms /etc/mdadm/mdadm.conf has an ARRAY line with the array's UUID.
- Confirms the array mounts and both original files have their original content.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
