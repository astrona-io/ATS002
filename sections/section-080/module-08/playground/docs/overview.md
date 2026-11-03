# Overview: Software RAID Recovery Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-raid-recovery-bench`.
- Three spare 1 GB disks with the serials `lab089-raid-a`, `lab089-raid-b` and `lab089-raid-c`. Find them at `/dev/disk/by-id/virtio-<serial>`. Their device letters are not fixed, so never type a raw `/dev/vdX` name.
- A RAID 1 array `/dev/md/cargo` built from disks `a` and `b`, with an ext4 filesystem (label `CARGO`) holding `marker.txt` and `logs/flight.log`. It is not mounted.
- Disk `c` is blank: it is your spare.
- `mdadm`, `lsblk` and `blkid`.
- Your own machine stays healthy and reachable; the damaged array lives on the spare disks.

## Things to try

- Check the health: `cat /proc/mdstat` and `sudo mdadm --detail /dev/md/cargo`.
- Set variables for the disks: `DISK_B=$(readlink -f /dev/disk/by-id/virtio-lab089-raid-b)` and likewise for `a` and `c`.
- Read a member's label: `sudo mdadm --examine "$DISK_B"`.
- Break it on purpose: `sudo mdadm /dev/md/cargo --fail "$DISK_B"`, then `--remove`, then add disk `c` with `--add` and watch `/proc/mdstat`.
- Save the array: `sudo mdadm --detail --scan`.

## When you are done

```sh
astrona destroy raid-recovery-bench
```

`astrona destroy` takes the playground's name, `raid-recovery-bench`, not the folder path. The running machine is called `astro-raid-recovery-bench`.
