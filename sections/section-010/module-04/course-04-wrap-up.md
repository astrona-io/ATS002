# Wrap-Up: Mission Debrief

Well flown, astronaut. You taught the dock master to recognise one cargo bay by its hull serial number, whatever order the bays arrive in. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about giving a disk a name that does not depend on the order the kernel found it.

**From [Device Events And A Stable Identity](./course-01-device-events-and-identity.md):**

- The kernel sends a uevent and fills `/sys` when it finds a device. `systemd-udevd` runs its rules and creates the `/dev` node and any links.
- A kernel name such as `sdc` only shows the order of discovery. It can change on the next boot.
- `udevadm info --query=all` shows the properties udev recorded. `udevadm info --attribute-walk` climbs the parent chain and finds attributes such as `ATTRS{serial}`.

**From [Writing The udev Rule](./course-02-writing-the-rule.md):**

- Your rules go in `/etc/udev/rules.d/` with a `99-` prefix, so they run after the built-in rules and survive package updates.
- `==` and `!=` test. `=`, `+=`, `-=` and `:=` assign. One missing `=` turns a test into an action with no error.
- `ATTR{}` matches only the device itself. `ATTRS{}` also matches its parents.
- `SYMLINK+=` adds a name and keeps the built-in links. `SYMLINK=` replaces them.

**From [Applying And Using The Rule](./course-03-applying-verifying-and-using.md):**

- `udevadm control --reload-rules` reads the rule files again. `udevadm trigger` applies them to devices already attached. You need both.
- `udevadm test` dry-runs the rules for one device without changing `/dev`. `udevadm monitor --udev` shows events live.
- The real fix is pointing scripts and `/etc/fstab` at the stable name. Check `/dev/disk/by-id/` and `/dev/disk/by-uuid/` first.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Stable Device Naming with udev Lab](./labs/lab-01/README.md) | Applying And Using The Rule | found a backup disk's serial and gave the disk and its partition stable names with a udev rule, applied without a reboot |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why can a disk that was <code>/dev/sdb</code> yesterday be <code>/dev/sdc</code> today?</summary>

The kernel hands out letters in the order it discovers disks on each boot. Another disk found first moves every later letter along.
</details>

<details>
<summary>2. <code>udevadm info --query=all</code> does not show the serial. What do you run next?</summary>

`udevadm info --attribute-walk --name=<device>`. It climbs the parent chain in sysfs, where the serial often sits as `ATTRS{serial}`.
</details>

<details>
<summary>3. What is the difference between <code>SUBSYSTEM=="block"</code> and <code>SUBSYSTEM="block"</code>?</summary>

`==` is a test: the rule applies only to block devices. `=` is an assignment: it sets the subsystem instead of testing it, so the rule stops filtering, with no error.
</details>

<details>
<summary>4. Why use <code>SYMLINK+=</code> and not <code>SYMLINK=</code>?</summary>

`SYMLINK` is a list. `+=` adds your name to the links the built-in rules already made. `=` replaces the list and drops links such as `/dev/disk/by-id/...`.
</details>

<details>
<summary>5. Where do you save your own rule, and why there?</summary>

In `/etc/udev/rules.d/`, with a `99-` prefix. Package updates never touch that folder, and `99-` makes the rule run after the built-in rules, so properties such as `ID_FS_TYPE` are already set.
</details>

<details>
<summary>6. You ran <code>udevadm control --reload-rules</code> and the link still does not exist. What is missing?</summary>

`udevadm trigger`, for example `sudo udevadm trigger --subsystem-match=block`. Reloading only reads the rules; trigger makes udev run them against devices that are already attached.
</details>

<details>
<summary>7. How can you check that a rule matches without changing <code>/dev</code>?</summary>

Run `udevadm test "$(udevadm info -q path -n /dev/<device>)"`. It prints which rules matched and which links they would create.
</details>

## Clean up the playground

Your playground and any mission each run a virtual machine on your computer. When you are done with this module, remove what is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy udev-stable-naming
```

If the mission is still running, remove it too:

```sh
astrona destroy ats-002-lab-014
```

> *Match the hull serial number, not the bay number, and always trigger after you reload.*
