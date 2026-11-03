# Solution Walkthrough

The default boot target is one symlink. Read where it points, move it with one command, and check it again.

## 1. Check the current default

Read the default target and the link behind it:

```bash
systemctl get-default
# graphical.target

readlink -f /etc/systemd/system/default.target
# /usr/lib/systemd/system/graphical.target
```

`/etc/systemd/system/default.target` is a symlink. `get-default` only reads where it points.

## 2. Set the new default

Point the link at `multi-user.target`:

```bash
sudo systemctl set-default multi-user.target
```

```text
Removed /etc/systemd/system/default.target.
Created symlink /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target.
```

`set-default` replaces the symlink. Nothing changes on the running system; only the next boot is affected.

## 3. Verify

Read the default and the link again:

```bash
systemctl get-default
# multi-user.target
readlink -f /etc/systemd/system/default.target
# /usr/lib/systemd/system/multi-user.target
```

The grader checks exactly these two things: `systemctl get-default` reports `multi-user.target`, and `/etc/systemd/system/default.target` resolves to `multi-user.target`. When both hold, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-06
```

## Related commands (not needed for this task)

These change the target in other ways:

```bash
sudo systemctl isolate multi-user.target      # switch the RUNNING system now
systemctl list-units --type=target            # which targets are active
# at the boot loader, append to the kernel line for ONE boot:
#   systemd.unit=rescue.target
```

`graphical.target` builds on `multi-user.target`: it pulls in everything a server needs, plus a graphical login. `rescue.target` is a much smaller maintenance mode, and `poweroff.target` shuts the machine down.
