# Overview: Disk Health Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-disk-health-bench`.
- Two spare 1 GB disks with the serials `lab08a-suspect` and `lab08a-other`. Find them at `/dev/disk/by-id/virtio-<serial>`. Their device letters are not fixed, so never type a raw `/dev/vdX` name.
- A pattern in the first MiB of the suspect disk, and its hash in `/var/lib/lab08a/suspect.sha256`.
- An `I/O error` line about the suspect disk in the kernel log, written by `lab08a-monitor`.
- `smartctl`, `badblocks`, `lsblk` and `dmesg`.
- Your own machine stays healthy and reachable; only the spare disks are scanned.

## Things to try

- List the disks: `lsblk -d -o NAME,SIZE,TYPE,SERIAL`.
- Ask for health: `sudo smartctl -H "$(readlink -f /dev/disk/by-id/virtio-lab08a-suspect)"`. A virtual disk has no SMART data.
- Find the error: `sudo dmesg | grep -i 'i/o error'`.
- Scan it safely: `sudo badblocks -sv <suspect disk>`, then compare `head -c 1048576 <disk> | sha256sum` with the stored hash.
- Only in this playground, try `badblocks -wsv` on the `lab08a-other` disk and see the pattern gone.

## When you are done

```sh
astrona destroy disk-health-bench
```

`astrona destroy` takes the playground's name, `disk-health-bench`, not the folder path. The running machine is called `astro-disk-health-bench`.
