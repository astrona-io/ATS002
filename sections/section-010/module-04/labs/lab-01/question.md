# Question

Solve this question on: `terminal`

Astronaut, a nightly backup script on this ship names its backup disk by a raw `/dev/vdX` path. That is fragile. The kernel hands out disk letters in the order it discovers the disks, so one extra disk found first can move the backup disk to another letter, and the script then writes to the wrong disk without any error.

The backup disk is the extra disk that already holds one ext4 partition. Give it names that never change:

1.  Find the backup disk and a stable attribute it carries, such as its serial number. `lsblk`, `udevadm info --query=all --name=/dev/vdX` and `udevadm info --attribute-walk --name=/dev/vdX` help here.
2.  Write a custom udev rule in a file under `/etc/udev/rules.d/` that matches the disk by that stable attribute, not by its device letter. The rule must create:
    - `/dev/backup-drive`, a link to the whole disk;
    - `/dev/backup-drive1`, a link to its first (ext4) partition.
3.  Apply the rule now, without rebooting.

The grader checks that a rule under `/etc/udev/rules.d/` mentions `backup-drive`, that `/dev/backup-drive` points to the disk with the backup serial, and that `/dev/backup-drive1` points to that disk's first partition.
