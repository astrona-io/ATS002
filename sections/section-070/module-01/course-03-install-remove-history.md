# Installing, Removing and Reading History

Installing and removing with `zypper` works much like any other tool for RPM packages. The one thing to get exactly right is `zypper history`. It is a record of what happened, not a list of steps you can reverse, unlike `dnf history undo` on Red Hat systems.

Run every command inside the `zypperbox` container as root.

## Install and remove

Here is the pair of commands you will use most:

```bash
# shell: inside the zypperbox container, root
zypper install fail2ban          # shorthand: zypper in
zypper remove telnet-server      # shorthand: zypper rm
```

`zypper` works out which packages to add or take away, including dependencies. Under it, openSUSE uses **RPM** (the RPM Package Manager) as its loading crew: the RPM layer unpacks each crate's files and writes them into the RPM database, the ledger of every crate on board.

Because RPM does the removal, it also decides what happens to configuration files. A package marks some of its files as configuration files (RPM calls them `%config` files). On removal, RPM checks each one:

- A configuration file that nobody changed since the package installed it is deleted with the rest.
- A configuration file you edited is kept, renamed with an `.rpmsave` ending, so your changes are not lost.

There is **no `zypper purge`** like the `remove` and `purge` pair in `apt`. RPM makes the keep-or-delete decision automatically, file by file, based on whether the file was changed.

## `zypper history`: a record, not a rewind

`zypper` writes every operation (install, remove, patch) into an ordered log with a timestamp on each line. Read it like this:

```bash
zypper history
```

```text
2026-02-14 09:12:03|patch  |install|patch:openSUSE-2026-142|1|noarch||
2026-02-14 09:14:41|install|install|fail2ban|1.0.2-1.5|noarch|repo-oss|
2026-02-14 09:15:09|remove |remove |telnet-server|1.2-1.30|noarch||
```

This is a true audit trail: exactly what happened and in what order. It is very useful when you need to rebuild the story of a maintenance window afterwards.

The log is also a plain file, `/var/log/zypp/history`, so `grep`, `awk` and `tail` work on it directly. If your `zypper` answers that `history` is an unknown command, read the file itself with `tail -n 10 /var/log/zypp/history`. Your own lines may have more columns (for example the user who ran the command) and look a little different from the sample above, which is shortened.

## Undoing a change by hand

Be clear about what the log is **not**. There is **no `zypper history undo`**. With `dnf history undo <id>` on Red Hat systems, the tool reverses a past transaction for you. The `zypper` log is only a record, so you reverse a change yourself, using the log as your guide:

- Reinstall what was removed: `zypper in <pkg>`.
- Remove what was newly installed: `zypper rm <pkg>`.
- Install a specific older version, if the repository still has it: `zypper in <pkg>=<version>`. Add `--oldpackage` when you deliberately want to go back to an older version.

In short: `zypper in` and `zypper rm` install and remove, with RPM keeping changed configuration files as `.rpmsave` (there is no `purge`); `zypper history` and `/var/log/zypp/history` are an audit log only, so any reversal is manual.

## Common pitfalls

> [!WARNING]
> - **Looking for `zypper purge`.** There is none. RPM's file-by-file `.rpmsave` logic runs automatically on `zypper rm`.
> - **Expecting `zypper history undo`.** It does not exist. Reverse changes by hand, guided by the log.
> - **Not noticing `.rpmsave` files after a removal.** Check `/etc` for them. They hold your changed configuration.
> - **Assuming the log rolls back the system.** `/var/log/zypp/history` is a record that only grows. It changes nothing by itself.

## Your mission: Zypper Basic Package Operations Lab

You can now refresh metadata, tell updates from patches, apply the right one, install and remove packages, and read the history log. The mission asks you to run a full maintenance pass on an openSUSE host under a conservative, security-focused policy.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-070/module-01/labs/lab-01
astrona ssh ats-002-lab-071
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-070/module-01/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-071
```
