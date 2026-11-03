# Overview: LVM Recovery Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-lvm-recovery-bench`.
- A second, 1 GB disk with the serial `lab088-pv001`. Find it at `/dev/disk/by-id/virtio-lab088-pv001`. Its device letter is not fixed, so never type a raw `/dev/vdX` name.
- On that disk, one LVM physical volume, a volume group `cargo_vg` and a logical volume `deck` of 400 MB with an ext4 filesystem (label `DECK`) holding `marker.txt` and `logs/flight.log`.
- The LVM text backup of the group in `/etc/lvm/backup/cargo_vg`.
- `pvs`, `vgs`, `lvs`, `vgchange`, `vgcfgrestore` and `lsblk`.
- Your own machine stays healthy and reachable; the damaged system lives on the spare disk.

## Things to try

- Read the three layers: `sudo pvs`, `sudo vgs`, `sudo lvs`, and `lsblk -f`.
- Switch the group off and on: `sudo vgchange -an cargo_vg`, then `sudo vgchange -ay cargo_vg`.
- List the saved layouts: `sudo vgcfgrestore --list cargo_vg`.
- Break it on purpose, with the group switched off: `sudo dd if=/dev/zero of=$(readlink -f /dev/disk/by-id/virtio-lab088-pv001) bs=1M count=1 conv=notrunc`. Then bring it back with `pvcreate --uuid ... --restorefile` and `vgcfgrestore`.
- Never run `mkfs` on the deck to "fix" it. That destroys the files.

## When you are done

```sh
astrona destroy lvm-recovery-bench
```

`astrona destroy` takes the playground's name, `lvm-recovery-bench`, not the folder path. The running machine is called `astro-lvm-recovery-bench`.
