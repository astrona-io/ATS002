# Writing The udev Rule

Astronaut, a udev rule is a line on the dock master's rule card. It is one line of **keys** separated by commas, and every key is either a *test* ("is this the bay I mean?") or an *action* ("then give it this name"). One wrong operator turns a test into an action, and udev does not warn you.

This part covers where the rule file goes, the operators, and a worked two-line rule.

## A worked rule first

Here is a complete rule file for a backup disk on a physical server, matched by the serial that the attribute walk found:

```
# /etc/udev/rules.d/99-backup-drive.rules
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", ENV{ID_FS_TYPE}=="ext4", SYMLINK+="backup-drive1"
```

Line 1 matches the whole disk and adds `/dev/backup-drive`. Line 2 narrows the match to the `ext4` partition on that same disk and adds `/dev/backup-drive1`. That partition is the node a backup script would actually mount. The rest of this part explains every piece of these two lines.

## Where the rule file goes, and why it wins

udev reads rule files from three folders. Which folder you choose decides whether your rule survives the next package update.

### The three folders

| Folder | Who writes it |
| --- | --- |
| `/etc/udev/rules.d/` | You, the administrator. Package managers never touch this folder. |
| `/run/udev/rules.d/` | Generated at runtime. |
| `/usr/lib/udev/rules.d/` | Ubuntu and its packages. A package update can rewrite these files. |

### The order udev reads them in

udev merges all three folders and processes the files **in alphabetical order by file name**. A file in `/etc` replaces a file with the same name in `/usr/lib`. Put your own rules in `/etc/udev/rules.d/`, never in `/usr/lib/udev/rules.d/`, where the next package update can undo them.

The usual `99-` prefix sorts your rule *after* the built-in rules. So your rule runs on top of the properties those rules already set, such as `ID_FS_TYPE` and `ID_SERIAL`.

## Match keys versus assignment keys

The operator decides whether a key tests something or sets something. The manual page `man 7 udev` draws the line like this:

| Operator | Kind | Meaning |
|---|---|---|
| `==` | **match** | this condition must be true or the rule does not apply |
| `!=` | **match** | must be false |
| `=` | **assign** | set this value |
| `+=` | **assign** | append to a list-valued key |
| `-=` | **assign** | remove from a list-valued key |
| `:=` | **assign** | set, and forbid later rules from changing it |

In `SUBSYSTEM=="block"`, the `==` makes the key a *test*. If you type `SUBSYSTEM="block"` (one `=`) by mistake, you tell udev to *set* the subsystem. The meaning changes, and no error appears.

## The keys in the worked rule

Each key in the worked rule does one job. Here they are in the order they appear.

### Keys that test

- **`SUBSYSTEM=="block"`** matches the device's own subsystem. `SUBSYSTEMS==` (with S) would match any subsystem in the parent chain.
- **`ATTRS{serial}=="…"`** matches a sysfs attribute on the device **or any of its parents**. `ATTR{}` without the S matches only the device's own attributes, so a serial on a parent needs `ATTRS{}`.
- **`ENV{ID_FS_TYPE}=="ext4"`** matches a udev *property*. The built-in `blkid` rules set `ID_FS_TYPE` earlier in the chain. Your `99-` rule runs after them, so the value is ready. This is why file order matters.

### The key that acts

**`SYMLINK+="backup-drive"`** uses `+=`, not `=`, because `SYMLINK` is a list. `+=` **adds** your name to the links the built-in rules already made, such as `/dev/disk/by-id/...`. `SYMLINK="backup-drive"` would *replace* the whole list and drop the built-in links.

The kernel node `/dev/sdc` stays the same either way. `/dev/backup-drive` is an extra path to the same device.

### Other common match keys

You will also meet these:

- `KERNEL=="sd*"`: the kernel name. Avoid depending on it.
- `ACTION=="add"`: only when a device arrives.
- `ATTRS{idVendor}=="0781"` with `ATTRS{idProduct}=="5567"`: the USB vendor and product numbers, useful when a device has no serial.
- `ENV{ID_FS_UUID}=="…"`: the filesystem's unique ID.

## Try it: write the rule

Write a rule for your playground's spare disk, matched by the serial you found with `udevadm info`. This virtio disk shows the serial as `ATTR{serial}`, but the `ENV{ID_SERIAL}` form works too, and it works on more kinds of disk.

<!-- astrona:playground:renew -->

Save this as `/etc/udev/rules.d/99-backup.rules`:

```
SUBSYSTEM=="block", ENV{ID_SERIAL}=="BACKUPWD42", SYMLINK+="backup-drive"
```

Then check the result:

```bash
cat /etc/udev/rules.d/99-backup.rules
```

Nothing happens to the disk yet. The file is on disk, but udev has not read it again and has not checked `/dev/vdc` again. Applying it takes two separate commands: `udevadm control --reload-rules` to read the file, then `udevadm trigger` to run the rules against the disk.

Note the `==` on every condition and the `+=` (not `=`) on `SYMLINK`. That keeps the built-in `/dev/disk/by-id/` link next to your new name.

For more detail, `man 7 udev` lists every key and operator, and the built-in file `/usr/lib/udev/rules.d/60-persistent-storage.rules` shows how properties such as `ID_FS_TYPE` get set.

> *A udev rule is a line of comma-separated keys. `==` and `!=` test, while `=`, `+=` and `:=` assign. `SYMLINK+=` adds a name without dropping the built-in links, `ATTRS{}` matches up the parent chain, and the file belongs in `/etc/udev/rules.d/` with a `99-` prefix.*

## Common pitfalls

> [!WARNING]
> - **`=` where you meant `==`.** `SUBSYSTEM="block"` is an assignment, not a test, so the rule stops filtering without any warning. Always use `==` for conditions.
> - **`ATTR{}` when the attribute is on a parent.** Use `ATTRS{}` (with S) for a serial or model that `--attribute-walk` showed under a *parent device*.
> - **`SYMLINK=` instead of `SYMLINK+=`.** `=` replaces the list of links and removes Ubuntu's `by-id` and `by-uuid` links. Use `+=`.
> - **Editing a file under `/usr/lib/udev/rules.d/`.** A package update undoes it. Put the rule in `/etc/udev/rules.d/` with a `99-` prefix.
