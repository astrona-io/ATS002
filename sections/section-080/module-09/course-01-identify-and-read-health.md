# Identify The Disk And Read Its Health

Astronaut, the first rule of diagnosis is to look at the right bay. This part shows how to name a disk safely and how to ask it about its own health.

## Name the disk by something that does not change

Device names such as `/dev/vdb` are handed out in the order the kernel finds the disks, so they can change between boots. Two things stay put: the serial number and the UUID of a filesystem. The links under `/dev/disk/by-id` use the serial number, so they always point at the same physical disk.

<!-- astrona:playground:renew -->

```bash
# shell: playground, no special rights
ls -l /dev/disk/by-id/ | grep lab08a
```

Each link shows a serial and the real device it points to. To get the real device name into a variable:

```bash
SUSPECT=$(readlink -f /dev/disk/by-id/virtio-lab08a-suspect)
echo "$SUSPECT"
```

## Read the size and type with lsblk

`lsblk` lists block devices as a tree. Ask for the columns you need, and `-d` to show only the disk, not its partitions:

```bash
lsblk -d -o NAME,SIZE,TYPE,SERIAL,MODEL
```

The disk mounted as `/` is your ship's own hull. The spare disks have no mount point. For an exact size in bytes, which is what a script compares, add `-b` and ask for one column without a header:

```bash
lsblk -bdno SIZE "$SUSPECT"
```

## Ask the disk about its health

Most real disks carry SMART, a built-in self-monitoring system that counts things like reallocated sectors. `smartctl`, from the `smartmontools` package, reads it. Three forms matter:

```bash
sudo smartctl -i "$SUSPECT"
sudo smartctl -H "$SUSPECT"
sudo smartctl -A "$SUSPECT"
```

`-i` prints the identity (model, serial, capacity). `-H` prints the overall verdict, `PASSED` or `FAILED`. `-A` prints the table of attributes, such as `Reallocated_Sector_Ct` and `Current_Pending_Sector`; a value above zero for those two is a warning on a real disk.

Your playground disks are virtual, so they have no SMART data. `smartctl` then says so, or says it cannot detect the device type. That is a normal answer, not an error on your side. The skill is to read the answer: on real hardware you would see a verdict, and on a virtual disk you rely on the kernel log and on a scan instead.

`smartctl` exits with a non-zero status when it finds a problem or cannot read the disk. To keep its text in a file, join the error output too: `sudo smartctl -H "$SUSPECT" 2>&1 | tee smart.txt`.

## Common pitfalls

- Typing a raw `/dev/vdb` from memory. Look the disk up by its serial every time.
- Running `smartctl` on a partition such as `/dev/sda1`. SMART belongs to the whole disk.
- Reading "no SMART data" as "the disk is healthy". It only means there is nothing to read.
