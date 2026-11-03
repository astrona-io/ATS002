# Keeping The Journal

Astronaut, a ship's log only helps if it still exists when you need it. After a reboot, `journalctl -b -1` should show you the previous boot. Sometimes it shows nothing at all. This part explains why: the log keeper, `journald`, can keep the journal in memory only, or on disk. You will see which setting decides that, how to keep the journal across reboots, and how to stop it from growing without limit.

## Storage: why `-b -1` can be empty

Whether the previous boot can still be read depends on one setting, `Storage=`, in the `[Journal]` section of `/etc/systemd/journald.conf` (or in a drop-in file under `/etc/systemd/journald.conf.d/`). This section shows the three values and what each one means after a reboot.

### The three values of `Storage=`

| `Storage=` | The journal lives in | Survives a reboot? |
|---|---|---|
| `volatile` | `/run/log/journal/` (a memory-only file system, `tmpfs`) | no |
| `persistent` | `/var/log/journal/` | yes |
| `auto` (the default) | `/var/log/journal/` **if that folder exists**, otherwise `/run/log/journal/` | only if the folder exists |

With `volatile`, the log keeper writes the log on a whiteboard that is wiped when the reactor shuts down. With `persistent`, it writes in a bound logbook that stays on board. `auto` uses the logbook only if somebody has already put one on the shelf, that is, only if `/var/log/journal/` exists.

### What an empty previous boot really means

Whether `/var/log/journal/` exists depends on how the machine was built. If nobody created it, `auto` means volatile. So `journalctl -b -1` returning nothing is **not** proof that the previous boot was clean. It may simply not have been kept.

## Making the journal persistent

The quickest way to keep the journal with `Storage=auto` is to create the folder it is waiting for, and then restart the log keeper so it starts using it.

<!-- astrona:playground:renew -->

Create the folder, give it the right owner and permissions, and restart `journald`:

```bash
# shell: host, root
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

`systemd-tmpfiles` sets the owner, group and permissions that `systemd` expects on the folder. Restarting `systemd-journald` makes the log keeper notice the folder and start writing there. From now on, each boot's log stays on disk.

The other way is to set `Storage=persistent` in the `[Journal]` section of the configuration. With `persistent`, `journald` creates `/var/log/journal/` itself if it is missing. Like any `journald` setting, it only takes effect after `systemd-journald` is restarted.

## Keeping the journal bounded

A journal on disk grows. By default `journald` lets it use up to 10% of the file system it sits on (and never more than 4 GB). On a small or busy server that can still be far too much, so `journald.conf` has settings to cap it:

- **`SystemMaxUse=`** sets the most disk space the journal under `/var/log/journal/` may use, for example `500M`. When it reaches the limit, `journald` deletes the oldest archived journal files to stay under it.
- **`MaxRetentionSec=`** sets the oldest entry `journald` keeps, for example `1month`.

Each setting goes in the `[Journal]` section. The manual page `man journald.conf` describes them all.

Three commands show and trim what is kept:

- `journalctl --disk-usage` prints how much space the journal uses right now.
- `journalctl --list-boots` lists the boots that are still in the journal.
- `journalctl --vacuum-time=7d` deletes archived entries older than seven days now, without waiting for the limit. `--vacuum-size=` does the same by size.

### See it in your playground

In your playground, run `journalctl --disk-usage` and `journalctl --list-boots`. The first one tells you how much space the journal takes right now. The boot list shows how many boots you could read with `-b -1`, `-b -2` and so on. A fresh playground has only booted once, so expect a single boot in the list.

## Common pitfalls

> [!WARNING]
> - **An empty `-b -1` means "not kept", not "no errors".** Check `Storage=` and whether `/var/log/journal/` exists before you decide the previous boot was fine.
> - **Writing the setting but not applying it.** `journald` reads its configuration when it starts. After you change `journald.conf` or a drop-in, run `sudo systemctl restart systemd-journald`.
> - **Putting the setting in the wrong section.** `Storage=` and `SystemMaxUse=` belong under the `[Journal]` header.

> *`Storage=auto` keeps the journal on disk only if `/var/log/journal/` exists, so an empty previous boot may just mean the log was never kept. Make the journal persistent, cap it with `SystemMaxUse=`, and restart `systemd-journald` to apply it.*

## Your mission: Configure journald: Persistent & Bounded Lab

You can now tell a memory-only journal from one kept on disk, and you know which settings keep it and cap its size. The mission gives you a machine whose journal is lost at every reboot and has no size cap of its own, and asks you to make it persistent and bounded.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy systemd-service-debugging
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-05
astrona ssh ats-002-lab-016e
```

Read the task in [`question.md`](./labs/lab-05/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-05
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-016e
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/playground
```
