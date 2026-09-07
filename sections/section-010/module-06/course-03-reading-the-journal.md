# Part 3 — Reading the journal

> Prerequisite: [Part 2 — The effective unit definition](./course-02-the-effective-unit-definition.md). Next: [Part 4 — Failure shapes, and proving the fix](./course-04-failure-shapes-and-proving-the-fix.md).

Part 1's `systemctl status` gave you a ten-line tail. The full account of a failed start is in the **journal** — and the journal is not a text file, it is a structured store you query by field. This part is how that store works, how `-u` actually filters it, how to slice it down to one incident, and why the previous boot's log is sometimes just... gone.

## The journal is fields, not lines

`syslog` wrote lines of text. `journald` writes **entries**, and each entry is a set of `FIELD=value` pairs. A single log message from Apache carries, among others:

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

Fields starting with `_` are **trusted** — journald sets them itself from the kernel and the sending process's cgroup, so they cannot be spoofed by the message text. Every `journalctl` filter is a match on one of these fields; the readable line you normally see is just `MESSAGE` with a formatted timestamp and `_COMM` prepended.

See the raw fields for any entry with `-o verbose`:

```bash
# shell: any host; unprivileged sees its own + world logs, root/adm group sees all
journalctl -u apache2 -o verbose -n 1
```

## `-u` is a field match, plus the manager's side of the story

```bash
journalctl -u apache2
```

`-u apache2` (`--unit`) does more than `_SYSTEMD_UNIT=apache2.service`. It unions:

- entries the service's own processes logged (`_SYSTEMD_UNIT=apache2.service`);
- entries **PID 1 logged *about* the unit** (`Starting…`, `Failed with result 'exit-code'`, `Scheduled restart`) — these have `_PID=1`, not the unit;
- coredump and `systemd-coredump` records for the unit's processes.

That union is why `journalctl -u` shows both `apachectl[4494]: bind failed` **and** `systemd[1]: apache2.service: Failed with result` interleaved — the service's symptom and the manager's verdict in one stream.

## Slicing to one incident

The flags, and the field each one is really matching:

| Flag | Matches / does | Field |
|---|---|---|
| `-b` / `-b -1` | this boot / the previous boot | `_BOOT_ID` |
| `--since "09:00"` `--until "09:15"` | time window | `__REALTIME_TIMESTAMP` |
| `-p err` | priority `err`(3) and worse; also `warning`(4), `notice`(5), `info`(6), `debug`(7) | `PRIORITY` |
| `-g 'bind'` / `--grep` | regex over `MESSAGE` | — |
| `-k` | kernel messages only | `_TRANSPORT=kernel` |
| `-n 50` / `-e` | last 50 / jump to end | (output window) |
| `-f` | follow — stream new entries | (live) |
| `-o verbose` / `-o json` | show all fields / machine form | (output format) |

The combination for a service that just failed:

```bash
journalctl -xeu apache2
```

`-x` adds a catalog paragraph for known message IDs (systemd's own messages mostly), `-e` jumps to the newest, `-u apache2` scopes it. If you are about to retry the start, run `journalctl -fu apache2` in a second terminal first and watch the attempt live.

## Storage: why `-b -1` can be empty

Whether yesterday's boot is still queryable depends on `Storage=` in `/etc/systemd/journald.conf`:

| `Storage=` | Journal lives in | Survives reboot? |
|---|---|---|
| `volatile` | `/run/log/journal/` (tmpfs) | no |
| `persistent` | `/var/log/journal/` | yes |
| `auto` (default) | `/var/log/journal/` **if that directory exists**, else `/run/log/journal/` | only if the dir exists |

On a stock install `auto` often means volatile, because nothing created `/var/log/journal/`. So `journalctl -b -1` returning nothing is **not** evidence the previous boot was clean — it may just not have been kept. To make it persistent:

```bash
# shell: host, root
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

Housekeeping commands: `journalctl --disk-usage`, `journalctl --list-boots` (what is actually retained), `journalctl --vacuum-time=7d`.

## Reading a failure cascade: first error, not last

Concrete. `journalctl -eu apache2` after a failed start:

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

Seven lines, one cause. `no listening sockets`, `Unable to open logs`, `Control process exited`, `Failed with result`, `Failed to start` are all **downstream** of the first real error: `(98)Address already in use` on `:80`. Read a cascade top-down and stop at the first line that names a concrete fault — the rest is the process and the manager unwinding from it. Part 4 maps that first line to a fix.

> [!WARNING]
> - **`-p err` can hide the cause.** Plenty of daemons log their fatal reason at `warning` or `notice` and only the generic "exiting" at `err`. If `-p err` shows nothing useful, widen to `-p warning` or drop `-p` entirely.
> - **An empty `-b -1` means "not retained", not "no errors".** Check `Storage=` before concluding the previous boot was fine.
> - **Reading bottom-up.** The last line (`Failed to start …`) is always the least specific. Start from the first concrete error, not the final summary.

> *The journal is queried by field: `-u <unit>` unions the service's own logs with PID 1's messages about it, `-b`/`--since`/`-p`/`-g` slice it to one incident, and default `Storage=auto` may not keep the previous boot at all — and in a failure cascade the first concrete error is the cause.*

## Reference

- `man systemd.journal-fields` — every `_`-prefixed trusted field and what sets it; the vocabulary for precise filters.
- `man journalctl` — `-u`, `-b`, `-p`, `-g`, `-o`, `--since`, `--list-boots`, `--vacuum-*`.
- `man journald.conf` — `Storage=`, `SystemMaxUse=`, `MaxRetentionSec=`; how much history the box keeps and where.
