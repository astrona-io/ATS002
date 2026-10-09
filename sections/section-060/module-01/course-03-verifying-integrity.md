# Verifying Integrity

Astronaut, loading a crate is not the end of the story. Files change after install. Sometimes that is a normal configuration edit, and sometimes it is something to worry about. `rpm -V` compares every file of a package with what the quartermaster's ledger recorded at install time. This part teaches you to read its short codes, and to read what a package needs and offers from the installed side.

## rpm -V: compare with the install-time record

`rpm -V` (verify) checks each file of an installed package against the size, checksum, owner, time and other details the RPM database stored when the package was installed.

### Run a verify

```bash
# shell: inside rpmbox
rpm -V logship-agent
```

**Clean output is no output at all.** `rpm -V` prints a line only for a file that fails one or more checks. A changed file looks like this:

```text
S.5....T.  c /etc/logship-agent/agent.conf
```

### Read the nine columns

The first field has nine columns, one per attribute. A `.` means "unchanged" and a letter means "changed":

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
| 9 | `P` | ca**P**abilities differ |

After the codes comes a **file-type marker**: `c` for a configuration file, `d` for documentation, `l` for a license, `g` for a ghost file (one the package owns but does not ship), and nothing at all for a normal file.

### What the example means

In the example, the size (`S`), checksum (`5`) and modification time (`T`) changed on a file marked `c`. Someone edited a configuration file. That is expected and harmless.

**The exact same `S.5....T.` on a program under `/usr/bin` with no `c` marker** is a serious warning. A program that is not a configuration file should never differ from what was installed. The marker after the codes is what changes how you read them.

To check every installed package at once, run `rpm -Va`. It is slow and prints many harmless `c` lines.

## Dependencies from the installed side

Every package lists what it needs and what it offers. Once a package is installed, you can read both lists from the RPM database.

### --requires and --provides

```bash
rpm -q --requires logship-agent
rpm -q --provides logship-agent
```

- **`--requires`** lists every **capability** the package needs to work. A capability is a named thing a package can offer or need: a library file name, another package, or an `rpmlib()` feature of `rpm` itself.
- **`--provides`** lists every capability the package *offers* to meet other packages' `Requires:` lines.

### Capabilities are not package names

The two lists are not mirror images, and a package's capabilities do not have to match its own name. `dnf` and `rpm` resolve dependencies by these capability strings, not by package names. For example, `python3` provides `python(abi) = 3.9`, and many packages require that string, not the name `python3`.

To go the other way round, `rpm -q --whatprovides <capability>` names the installed package that offers a capability, and `rpm -q --whatrequires <capability>` names the installed packages that need it.

## Common pitfalls

> [!WARNING]
> - **Reading `rpm -V` output as "the package is broken".** It only means *something differs from install time*. On a `c` configuration file, that is normal.
> - **Ignoring `S.5....T.` on a program with no marker.** That *is* alarming. Investigate it. The marker after the codes changes the meaning.
> - **Expecting output from a clean `rpm -V`.** Silence is success. No line means every checked attribute matches.
> - **Assuming `--provides` repeats the package name.** Capabilities are separate strings, and dependency resolution uses them, not the name.

## Your mission: RPM Low-Level Package Management Lab

You can now inspect a `.rpm` file, install it with `rpm`, answer ownership questions both ways and verify a package against its install-time record. The mission hands you a standalone `.rpm` and asks you to do all of that on a real Rocky Linux 9 container.

Start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-01/labs/lab-01
astrona ssh ats-002-lab-061
```

On the lab machine, open a shell inside the `rpmbox` container with `docker exec -it rpmbox bash`. Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-060/module-01/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-061
```
