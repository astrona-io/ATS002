# Solution Walkthrough

## 1. Check the current default

```bash
systemctl get-default
# graphical.target

readlink -f /etc/systemd/system/default.target
# /usr/lib/systemd/system/graphical.target
```

`default.target` is a symlink; `get-default` just reads what it points at.

## 2. Set the new default

```bash
sudo systemctl set-default multi-user.target
```

```text
Removed /etc/systemd/system/default.target.
Created symlink /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target.
```

`set-default` repoints that symlink. Nothing about the running system
changes — this only affects the next boot.

## 3. Verify

```bash
systemctl get-default
# multi-user.target
readlink -f /etc/systemd/system/default.target
# /usr/lib/systemd/system/multi-user.target
```

## Related commands (not needed for this task)

```bash
sudo systemctl isolate multi-user.target      # switch the RUNNING system now
systemctl list-units --type=target            # which targets are active
# at the boot loader, append to the kernel line for ONE boot:
#   systemd.unit=rescue.target
```

The target hierarchy, roughly: `poweroff` → `rescue` → `multi-user` →
`graphical`, each pulling in the one before it.
