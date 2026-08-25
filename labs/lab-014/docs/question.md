# Question

Solve this question on: `terminal`

A nightly backup script on this system hardcodes its target backup disk as a raw `/dev/vdX` device path. This is fragile: block device letters are assigned purely in kernel discovery order, and any additional disk attached ahead of it can silently bump it to a different letter, causing the script to write to the wrong device without any error.

1.  Identify the attached backup disk and find a stable identifying attribute for it (hint: `lsblk`, then `udevadm info --query=all --name=/dev/vdX` and/or `udevadm info --attribute-walk --name=/dev/vdX` — look for `ATTRS{serial}`).
2.  Write a custom udev rule under `/etc/udev/rules.d/` that creates a persistent `/dev/backup-drive` symlink for the whole disk, and a `/dev/backup-drive1` symlink for its ext4-formatted partition, matched by that stable attribute rather than the device letter.
3.  Apply the rule live, without rebooting (`udevadm control --reload-rules` + `udevadm trigger`).
4.  Verify both symlinks exist and resolve to the correct devices.
