# Part 3 — Installing, removing, and reading history

> Prerequisite: [Part 2 — Applying the right one: `zypper patch` vs `zypper update`](./course-02-applying-the-right-one.md). Next: [Section 070 quiz](../quiz.md).

Ordinary install and remove behave like any RPM-family tool. The one thing to be precise about: `zypper history` is an audit *log*, not a transaction ledger you can reverse — unlike `dnf history undo`.

## Install and remove

```bash
# shell: inside the zypperbox container, root
zypper install fail2ban          # shorthand: zypper in
zypper remove telnet-server      # shorthand: zypper rm
```

openSUSE is RPM-based underneath zypper, so removal follows RPM's own `%config` handling automatically (Module in Section 060, Part on removal):

- an unmodified config file that shipped with the package → deleted with the rest,
- a locally-edited one → preserved with an `.rpmsave` suffix, not destroyed.

There is **no `zypper purge`** mirroring APT's `remove`/`purge` split — the decision is per-file, automatic, based on RPM's modification check.

## `zypper history` — a record, not a rewind

Every zypper operation — install, remove, patch — is written to an ordered, timestamped log:

```bash
zypper history
```

```text
2026-02-14 09:12:03|patch  |install|patch:openSUSE-2026-142|1|noarch||
2026-02-14 09:14:41|install|install|fail2ban|1.0.2-1.5|noarch|repo-oss|
2026-02-14 09:15:09|remove |remove |telnet-server|1.2-1.30|noarch||
```

A genuine audit trail: exactly what happened and in what order, invaluable for reconstructing a maintenance window afterward.

But be precise about what it is **not**: there is **no `zypper history undo`**. Unlike `dnf history undo <id>`, zypper's history is a *record*, not a reversible ledger. To undo something you find there you do it **manually**, informed by the log:

- reinstall what was removed (`zypper in <pkg>`),
- remove what was newly installed (`zypper rm <pkg>`),
- install a specific older version explicitly if it is still available (`zypper in <pkg>=<version>`).

The log is also just a file — `/var/log/zypp/history` — so `grep`, `awk`, and `tail` work on it directly.

> [!WARNING]
> - **Looking for `zypper purge`** → there is none; RPM's per-file `.rpmsave` logic runs automatically on `zypper rm`.
> - **Expecting `zypper history undo`** → it does not exist. Reverse changes by hand, guided by the log.
> - **`.rpmsave` files unnoticed after a removal** → check `/etc` for them; they hold your customised config.
> - **Assuming the log rolls back state** → it is `/var/log/zypp/history`, an append-only record, nothing more.

> *`zypper in` / `zypper rm` install and remove with automatic RPM `%config` → `.rpmsave` handling (no `purge`); `zypper history` (`/var/log/zypp/history`) is an audit log only — there is no `zypper history undo`, so reversals are manual.*

## Reference

- `man zypper` — `install` / `in`, `remove` / `rm`, `history`; the shorthand aliases.
- `/var/log/zypp/history` — the raw pipe-delimited log, parseable with standard text tools.
- `man zypper` — `install <pkg>=<version>` and `--oldpackage` for a deliberate downgrade during a manual reversal.
