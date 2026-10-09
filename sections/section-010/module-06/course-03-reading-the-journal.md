# Reading The Journal

`systemctl status` gives you a ten-line tail. The full story of a failed start is in the **journal**: the ship's log. `journald` is the log keeper who writes it, and `journalctl` (journal control) is how you read it. The journal is not a text file. It is a store you search by field. This part shows how that store works, what `-u` really filters, how to cut the log down to one incident, and how to read a chain of errors to its cause.

## The journal is fields, not lines

The old `syslog` service wrote lines of text. `journald` writes **entries**, and each entry is a set of `FIELD=value` pairs. One log message from Apache carries these fields, among others:

```
  MESSAGE=AH00072: could not bind to [::]:80
  PRIORITY=3
  _SYSTEMD_UNIT=apache2.service
  _PID=4494
  _COMM=apachectl
  _BOOT_ID=9f2c...
  _TRANSPORT=stdout
  __REALTIME_TIMESTAMP=1757236324113000
```

Fields that start with `_` are **trusted**. `journald` sets them itself, from what the kernel tells it about the sending process and its control group (cgroup, the group the kernel uses to track a service's processes). The message text cannot fake them. Every `journalctl` filter is a match on one of these fields. The readable line you normally see is just `MESSAGE` with a timestamp and `_COMM` (the program name) in front. The manual page `man systemd.journal-fields` lists every trusted field and what sets it.

<!-- astrona:playground:renew -->

See all the fields of one entry with `-o verbose`:

```bash
# shell: any host; unprivileged sees its own + world logs, root/adm group sees all
journalctl -u apache2 -o verbose -n 1
```

## `-u` is a field match, plus the manager's side of the story

`-u` is the filter you will use most. Here it is:

```bash
journalctl -u apache2
```

`-u apache2` (long form `--unit`) does more than match `_SYSTEMD_UNIT=apache2.service`. It joins together:

- entries the service's own processes logged (`_SYSTEMD_UNIT=apache2.service`);
- entries that **PID 1 logged *about* the unit** (`Starting…`, `Failed with result 'exit-code'`, `Scheduled restart`). These carry `_PID=1`, not the unit;
- core dump records from `systemd-coredump` for the unit's processes.

That is why `journalctl -u` shows both `apachectl[4494]: bind failed` **and** `systemd[1]: apache2.service: Failed with result` mixed together. You get the service's symptom and the duty officer's verdict in one stream.

## Slicing to one incident

A busy machine logs thousands of lines. These options cut the journal down to the lines of one incident, and each one matches a field:

| Option | Matches or does | Field |
|---|---|---|
| `-b` / `-b -1` | this boot / the previous boot | `_BOOT_ID` |
| `--since "09:00"` `--until "09:15"` | a time window | `__REALTIME_TIMESTAMP` |
| `-p err` | priority `err` (3) and worse; the others are `warning` (4), `notice` (5), `info` (6), `debug` (7) | `PRIORITY` |
| `-g 'bind'` / `--grep` | a regular expression over `MESSAGE` | none |
| `-k` | kernel messages only | `_TRANSPORT=kernel` |
| `-n 50` / `-e` | the last 50 entries / jump to the end | (output window) |
| `-f` | follow: show new entries as they arrive | (live) |
| `-o verbose` / `-o json` | show all fields / a form for programs | (output format) |

The combination for a service that just failed is this one:

```bash
journalctl -xeu apache2
```

`-x` adds an explanation paragraph for known messages (mostly `systemd`'s own), `-e` jumps to the newest entries, and `-u apache2` limits it to the unit. If you are about to try the start again, first run `journalctl -fu apache2` in a second terminal, and watch the attempt live.

## Reading a failure chain: first error, not last

When a start fails, one fault usually causes a chain of error lines. This section shows how to find the line that matters.

### A real chain

Here is `journalctl -eu apache2` after a failed start:

```text
09:12:04 web01 systemd[1]: Starting The Apache HTTP Server...
09:12:04 web01 apachectl[4494]: (98)Address already in use: AH00072: make_sock: could not bind to [::]:80
09:12:04 web01 apachectl[4494]: (98)Address already in use: AH00072: make_sock: could not bind to 0.0.0.0:80
09:12:04 web01 apachectl[4494]: no listening sockets available, shutting down
09:12:04 web01 apachectl[4494]: AH00015: Unable to open logs
09:12:04 web01 systemd[1]: apache2.service: Control process exited, code=exited, status=1/FAILURE
09:12:04 web01 systemd[1]: apache2.service: Failed with result 'exit-code'.
09:12:04 web01 systemd[1]: Failed to start The Apache HTTP Server.
```

That is seven lines after the start line, and one cause. `no listening sockets`, `Unable to open logs`, `Control process exited`, `Failed with result` and `Failed to start` all **follow from** the first real error: `(98)Address already in use` on port 80.

The rule: read a chain from the top down, and stop at the first line that names a real fault. Everything after it is the process and the manager cleaning up after that fault.

### See it in your playground

In your playground, read the `apache2` chain to its first error:

```bash
journalctl -u apache2 -b --no-pager | tail -20
```

You should see something like this:

```text
... systemd[1]: Starting The Apache HTTP Server...
... apachectl[…]: (98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
... apachectl[…]: no listening sockets available, shutting down
... systemd[1]: apache2.service: Failed with result 'exit-code'.
... systemd[1]: Failed to start The Apache HTTP Server.
```

Several lines, one root cause. The bind failure on port 80 is the first real error. Everything below it is Apache and `systemd` cleaning up. `Failed to start …` at the bottom is the least useful line.

The manual page `man journalctl` describes every option in the table above.

## Common pitfalls

> [!WARNING]
> - **`-p err` can hide the cause.** Many programs log their real reason at `warning` or `notice`, and only a general "exiting" line at `err`. If `-p err` shows nothing useful, widen it to `-p warning` or drop `-p`.
> - **Reading from the bottom up.** The last line (`Failed to start …`) is always the least specific. Start from the first real error, not the final summary.
> - **Forgetting the manager's lines.** `journalctl -u` also shows what `systemd[1]` said about the unit. Those lines tell you the result, but the cause is usually in the service's own lines above them.

> *The journal is searched by field: `-u <unit>` joins the service's own logs with PID 1's messages about it, and `-b`, `--since`, `-p` and `-g` cut it down to one incident. In a failure chain, the first real error is the cause.*
