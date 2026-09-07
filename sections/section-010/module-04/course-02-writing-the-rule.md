# Part 2 — Writing the rule: match keys vs. assignment keys

> Prerequisite: [Part 1 — Device events, sysfs, and finding a stable identity](./course-01-device-events-and-identity.md). Next: [Part 3 — Applying, verifying, and using the rule](./course-03-applying-verifying-and-using.md).

A udev rule is a single line of comma-separated **keys**, and every key is either a *test* or an *action*. Mixing up the two operators silently changes what the rule does. This part is the rule file's location and precedence, the operator vocabulary, and a worked two-line rule.

## Where the rule file goes, and why it wins

```
  /etc/udev/rules.d/         ← your rules. Package managers never touch this.
  /run/udev/rules.d/         ← runtime-generated
  /usr/lib/udev/rules.d/     ← distro/package rules. A package update can rewrite these.
```

udev merges all three directories and processes the files **in lexical order by filename** across the merged set (a file in `/etc` with a given name replaces a same-named file in `/usr/lib`). Custom rules go in `/etc/udev/rules.d/` — never in `/usr/lib/udev/rules.d/`, where the next package update can revert them. The conventional `99-` prefix sorts your rule *after* the distro's built-in rules, so it layers on top of the `ID_FS_TYPE`, `ID_SERIAL` and similar properties they have already set.

## The rule

```
# /etc/udev/rules.d/99-backup-drive.rules
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", SYMLINK+="backup-drive"
SUBSYSTEM=="block", ATTRS{serial}=="WD-WXA1E23456789", ENV{ID_FS_TYPE}=="ext4", SYMLINK+="backup-drive1"
```

Line 1 matches the whole-disk device and adds `/dev/backup-drive`. Line 2 narrows to the `ext4` partition on that same disk and adds `/dev/backup-drive1` — the node a backup script would actually mount.

## Match keys vs. assignment keys — the operators

`man 7 udev` draws the line by operator:

| Operator | Kind | Meaning |
|---|---|---|
| `==` | **match** | this condition must be true or the rule does not apply |
| `!=` | **match** | must be false |
| `=` | **assign** | set this value |
| `+=` | **assign** | append to a list-valued key |
| `-=` | **assign** | remove from a list-valued key |
| `:=` | **assign** | set, and forbid later rules from changing it |

So in `SUBSYSTEM=="block"`, the `==` makes it a *test*. Write `SUBSYSTEM="block"` (one `=`) by accident and you have told udev to *set* the subsystem — a silent change of meaning, no error.

Key types used above:

- **`SUBSYSTEM=="block"`** — match the device's subsystem. `SUBSYSTEMS==` (with S) would match any subsystem in the parent chain.
- **`ATTRS{serial}=="…"`** — match a sysfs attribute anywhere **up the parent chain** (Part 1). `ATTR{}` without the S matches only the device's own attributes — a serial on a parent needs `ATTRS{}`.
- **`ENV{ID_FS_TYPE}=="ext4"`** — match a udev *property*. `ID_FS_TYPE` is set earlier in the rule chain by the built-in `blkid` rules; your `99-` rule runs after them, so the value is available. This is why file order matters.
- **`SYMLINK+="backup-drive"`** — `+=`, not `=`, because `SYMLINK` is a list. `+=` **appends** your name to whatever symlinks the built-in rules already assigned (`/dev/disk/by-id/...`, etc.). `SYMLINK="backup-drive"` would *replace* the whole list and drop the built-in links. The kernel node `/dev/sdc` is untouched either way — `/dev/backup-drive` is an additional path to it.

## Other common match keys

`KERNEL=="sd*"` (the kernel name — avoid depending on it), `ACTION=="add"`, `ATTRS{idVendor}=="0781"` + `ATTRS{idProduct}=="5567"` (USB VID/PID when there is no serial), `ENV{ID_FS_UUID}=="…"`.

> [!WARNING]
> - **`=` where you meant `==`.** `SUBSYSTEM="block"` is an assignment, not a test; the rule silently stops filtering. Always `==` for conditions.
> - **`ATTR{}` when the attribute is on a parent.** Use `ATTRS{}` (with S) for a serial/model that `--attribute-walk` showed under a *parent device*.
> - **`SYMLINK=` instead of `SYMLINK+=`.** `=` replaces the symlink list and removes the distro's `by-id`/`by-uuid` links. Use `+=`.
> - **Editing a file under `/usr/lib/udev/rules.d/`.** A package update reverts it. Put the rule in `/etc/udev/rules.d/` with a `99-` prefix.

> *A udev rule is comma-separated keys; `==`/`!=` test and `=`/`+=`/`:=` assign — `SYMLINK+=` appends a name without dropping the built-in links, `ATTRS{}` matches up the parent chain, and the file belongs in `/etc/udev/rules.d/` with a `99-` prefix.*

## Reference

- `man 7 udev` — the full key list, every operator, and string-matching (`*`, `?`, `[]`) in match values.
- `udevadm info --attribute-walk` output — the exact `SUBSYSTEM` / `ATTRS{}` / `KERNELS` strings to paste into a rule.
- `/usr/lib/udev/rules.d/60-persistent-storage.rules` — the built-in rules your `99-` file layers on; shows how `ID_FS_TYPE` etc. get set.
