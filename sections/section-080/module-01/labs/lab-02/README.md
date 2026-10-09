# chroot Repair: Wrong fstab Filesystem Type Lab

Welcome to a second rescue mission, astronaut. The `data-002` host has a `/data` line in its `/etc/fstab` that points at the right device, but still will not mount. `mount -a` fails with `wrong fs type, bad superblock`. You must check every field of the line against `blkid`, not just the device.

As before, the broken system is a stand-in on a second, disposable 2 GB disk (serial `lab085-data002`): a small root partition with its own `/etc/fstab`, and a data partition. Your own ship stays healthy and reachable over SSH the whole time.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-01/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-085
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-080/module-01/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-085
```
