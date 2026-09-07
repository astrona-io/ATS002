# Part 2 — The effective unit definition

> Prerequisite: [Part 1 — The service manager and unit state](./course-01-service-manager-and-unit-state.md). Next: [Part 3 — Reading the journal](./course-03-reading-the-journal.md).

Part 1's `systemctl status` told you which file the manager *loaded*. That is rarely the whole story: the definition the manager actually acts on is a **merge** of a base unit and any number of drop-in fragments, layered in a fixed precedence. This part is that merge — where fragments come from, which wins, how to see the resolved result, and why `daemon-reload` is not optional after you change any of it.

## The unit load path

When the manager needs `apache2.service`, it searches a list of directories **in priority order** and takes the first match as the base unit, then collects drop-ins from *all* of them. The system instance's path, highest priority first:

```
  /etc/systemd/system/        ← admin. You put overrides here. WINS.
  /run/systemd/system/        ← runtime-generated (tmpfiles, generators). Lost on reboot.
  /usr/lib/systemd/system/    ← vendor. The package ships the unit here. Lowest.
```

See it on the host:

```bash
# shell: any host, unprivileged
systemctl show -p UnitPath | tr ' ' '\n' | head
```

So a `apache2.service` placed in `/etc/systemd/system/` **completely replaces** the packaged one in `/usr/lib/systemd/system/`. That is a blunt instrument — a package update to the vendor unit will not reach a service you have fully shadowed. Drop-ins are the surgical alternative.

## Drop-ins: partial overrides that survive updates

A **drop-in** is a `.conf` file in a directory named after the unit:

```
  /etc/systemd/system/apache2.service.d/override.conf
  /etc/systemd/system/apache2.service.d/10-hardening.conf
```

The manager loads the base unit, then applies every `*.conf` in every `<unit>.d/` directory it found, **sorted lexically by filename** across all sources. Later files win on any setting they touch; settings they do not mention keep the base value.

```
  base unit (/usr/lib/.../apache2.service)
        │  Type=forking
        │  ExecStart=/usr/sbin/apachectl start
        ▼
  + 10-hardening.conf   PrivateTmp=true
        ▼
  + override.conf       Environment=APACHE_PORT=8080
        ▼
  = effective unit:  Type=forking, ExecStart=…apachectl start,
                     PrivateTmp=true, Environment=APACHE_PORT=8080
```

As an analogy (flagged): drop-ins are the CSS cascade for units — a later, more specific rule overrides an earlier one property-by-property, and anything it does not set is inherited. Where it breaks down: CSS has specificity weighting; systemd drop-ins are purely last-wins by sorted filename, so people prefix them `10-`, `20-` to control order.

**One sharp edge — list-valued directives.** Settings like `ExecStart=`, `Environment=`, `After=` are *additive lists*, not scalars. A drop-in line `ExecStart=/new/thing` **appends** a second start command (usually an error). To replace, you must reset the list first:

```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/apachectl -DFOREGROUND
```

The empty assignment clears the list; the next line sets the only entry. A scalar like `Type=` or `User=` just overrides directly, no reset needed.

## See the effective definition, not a guess

**`systemctl cat`** prints the base unit and every drop-in, each under a comment header naming its source file:

```bash
systemctl cat apache2
```

```text
# /usr/lib/systemd/system/apache2.service
[Unit]
Description=The Apache HTTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/apachectl start

# /etc/systemd/system/apache2.service.d/override.conf
[Service]
Environment=APACHE_PORT=80
```

Opening `/usr/lib/systemd/system/apache2.service` in a pager instead would miss `override.conf` entirely — and an override is exactly where a half-finished change from a colleague hides. `systemctl cat` is the first thing to run before editing anything.

**`systemctl show`** prints the *computed* properties — every value after the full merge, which is what the manager will actually act on:

```bash
systemctl show apache2 -p FragmentPath -p DropInPaths -p ExecStart -p User -p Type
```

```text
FragmentPath=/usr/lib/systemd/system/apache2.service
DropInPaths=/etc/systemd/system/apache2.service.d/override.conf
ExecStart={ path=/usr/sbin/apachectl ; argv[]=/usr/sbin/apachectl start ; ... }
User=
Type=forking
```

`FragmentPath` = the base unit; `DropInPaths` = every fragment layered on it. If `DropInPaths` lists a file you did not expect, read it.

## Editing, the safe way

```bash
# shell: host, root
sudo systemctl edit apache2          # create/modify /etc/.../apache2.service.d/override.conf
sudo systemctl edit --full apache2   # copy the whole unit to /etc/ and edit that
```

`systemctl edit` opens an empty drop-in in `$EDITOR`, writes it under `/etc/systemd/system/<unit>.d/`, and runs `daemon-reload` for you on save. `edit --full` instead copies the entire vendor unit into `/etc/systemd/system/` for wholesale changes (and shadows the vendor copy — same update caveat as above). Prefer plain `edit` unless you are rewriting most of the unit.

## `daemon-reload`: re-parse disk into the manager's memory

The manager parses every unit file **once, at boot**, into an in-memory dependency graph, and acts on that graph. Editing a file on disk changes nothing the manager sees until:

```bash
sudo systemctl daemon-reload
```

`daemon-reload` re-reads every unit file and drop-in from the load path and rebuilds the in-memory graph, **without stopping or restarting any running unit**. It is the systemd analogue of `nginx -s reload` re-reading `nginx.conf`, or `sysctl -p` re-reading `sysctl.conf`.

Two things it is *not*:

- It is **not** `systemctl reload apache2` — that runs the unit's `ExecReload=` command (tell the *service* to re-read *its own* config). Different layer entirely.
- It does **not** apply a changed `ExecStart=`/`Environment=` to the process that is already running. `daemon-reload` updates the plan; you still need `systemctl restart apache2` to relaunch the process under the new plan.

The manager tracks whether you owe it a reload:

```bash
systemctl show apache2 -p NeedDaemonReload
# NeedDaemonReload=yes
```

and `systemctl status` prints a `warning: The unit file … changed on disk. Run 'systemctl daemon-reload'` banner.

> [!WARNING]
> Two failure modes around this:
> - **Hand-edit a `.service` or drop-in, then `systemctl restart`, and see no change.** You skipped `daemon-reload`; the manager restarted the process under the *old* plan. Reload, then restart.
> - **Run `daemon-reload` and expect the running service to pick up a new `ExecStart=`.** It will not — `daemon-reload` only updates the plan. A config change to a running unit needs `restart` (or `reload` if only the service's own config changed and it supports it).

> *The effective unit is the base file plus every `<unit>.d/*.conf` drop-in merged last-wins by sorted filename; read it with `systemctl cat` / `systemctl show -p`, and after any edit run `daemon-reload` (updates the plan) then `restart` (relaunches under it).*

## Reference

- `man systemd.unit` — the "Unit File Load Path" and "drop-in" sections: every directory searched and the exact merge rules.
- `man systemd.directives` — which directives are list-valued (need the empty-reset idiom) versus scalar.
- `man systemctl` — `cat`, `show`, `edit`, `revert`, `daemon-reload`; `revert` deletes your drop-ins and returns a unit to its vendor state.
