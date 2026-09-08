# Part 3 — Verifying integrity

> Prerequisite: [Part 2 — Installing directly, and ownership queries in both directions](./course-02-installing-and-ownership.md). Next: [Section 060 quiz](../quiz.md).

Installing a package is not the end. Files drift — a legitimate config edit, or something worth worrying about. `rpm -V` answers "has anything changed since install?", and reading its compact per-attribute codes is the skill. This part also covers the `--requires` / `--provides` pair from the installed side.

## `rpm -V` — verify against what was recorded

```bash
# shell: inside rpmbox
rpm -V logship-agent
```

**Clean output is no output at all.** `rpm -V` prints a line only for a file that fails one or more checks:

```text
S.5....T.  c /etc/logship-agent/agent.conf
```

Nine columns, one per attribute compared against the install-time record. `.` = unchanged; a letter = changed:

| Col | Letter | Attribute |
|---|---|---|
| 1 | `S` | file **S**ize differs |
| 2 | `M` | **M**ode (permissions / type) differs |
| 3 | `5` | MD**5** / checksum differs (content changed) |
| 4 | `D` | **D**evice major/minor differs |
| 5 | `L` | symlink target (`L`) differs |
| 6 | `U` | **U**ser / owner differs |
| 7 | `G` | **G**roup differs |
| 8 | `T` | m**T**ime differs |
| 9 | `P` | **P**ie / capabilities differ |

After the codes, a **file-type marker**: `c` config, `d` doc, `l` license, `g` ghost, `(nothing)` = a normal file.

Reading the example: `S`, `5`, `T` changed on a file marked `c`. A config file that was edited — expected, harmless. **The exact same `S.5....T.` on a binary under `/usr/bin` with no `c` marker** would be a serious integrity flag: an unflagged executable should never differ from what was installed.

Verify the whole system: `rpm -Va` (slow; lots of legitimate `c` lines).

## Dependencies from the installed side

```bash
rpm -q --requires logship-agent
rpm -q --provides logship-agent
```

- **`--requires`** — every capability the package needs to function (library sonames, other packages, `rpmlib()` features).
- **`--provides`** — every capability the package *offers* to satisfy other packages' `Requires:`.

They are **not symmetric**. A package's provided capabilities need not match its own name — other packages' dependency resolution keys off exactly this `--provides` list, which is why a packager cares about it. Example: `python3` provides `python(abi) = 3.9`, and dozens of packages `Require:` that string, not the name `python3`.

> [!WARNING]
> - **Reading `rpm -V` output as "the package is broken"** → it only means *something differs from install time*. On a `c` config file, that is normal.
> - **Ignoring `S.5....T.` on an unflagged binary** → that *is* alarming — investigate. The file-type marker after the codes is what changes the interpretation.
> - **Expecting output from a clean `rpm -V`** → silence is success. No line = every checked attribute matches.
> - **Assuming `--provides` mirrors the package name** → capabilities are independent strings; dependency resolution uses them, not the name.

> *`rpm -V` prints one line per drifted file with a per-attribute code (`S` size, `5` checksum, `T` mtime, …) and a type marker (`c` = config); the same codes are benign on a `c` file and alarming on an unmarked binary — and `--provides` lists capabilities other packages depend on, which need not match the package name.*

## Reference

- `man rpm` "VERIFY OPTIONS" — the full nine-column legend and the file-type markers.
- `man rpm` — `--requires`, `--provides`, `--conflicts`, `--obsoletes`; `--whatprovides` / `--whatrequires`.
- `rpm -Va` and `rpmverify` — whole-system verification and the standalone verify tool.
