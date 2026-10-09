# Wrap-Up: Mission Debrief

Well flown, astronaut. You have worked through the loading crew's own tool, `rpm`, from reading a crate's label to checking its contents against the ledger. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about `rpm`, the low-level tool that installs one package at a time and keeps the RPM database.

**From [What rpm Knows and Inspecting a .rpm File](./course-01-rpm-scope-and-inspecting.md):**

- `rpm` works on one `.rpm` file or one installed package name, never on a repository.
- With `-p` (`rpm -qip`, `-qlp`, `-qp --requires`) it reads a file's header. Without `-p` it asks the installed database under `/var/lib/rpm`.
- Run `-qlp` and `-qp --requires` before you install, to see where a package writes and what it needs.

**From [Installing Directly and Ownership Queries](./course-02-installing-and-ownership.md):**

- `rpm -ivh` installs one file and refuses the whole transaction when a dependency is missing.
- `dnf install ./file.rpm` installs the same file and fetches missing dependencies from the repositories.
- `rpm -qf <path>` maps a file to its package. `rpm -ql <name>` maps a package to its files. Neither takes `-p`.

**From [Verifying Integrity](./course-03-verifying-integrity.md):**

- `rpm -V` prints nothing when every file matches its install-time record.
- Each changed file gets nine attribute columns (`S` size, `5` checksum, `T` time and so on) and a type marker (`c` for configuration).
- The same codes are harmless on a `c` file and alarming on a program with no marker.
- `--provides` lists capabilities that other packages depend on. They do not have to match the package name.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [RPM Low-Level Package Management Lab](./labs/lab-01/README.md) | Verifying Integrity | inspected a standalone `.rpm`, installed it with `rpm`, answered ownership questions and verified its files |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You run <code>rpm -qi ./tool.rpm</code> and get "package ./tool.rpm is not installed". What went wrong?</summary>

The `-p` flag is missing. Without it, `rpm` looks for an installed package with that name. `rpm -qip ./tool.rpm` reads the file's header instead.
</details>

<details>
<summary>2. <code>rpm -ivh</code> stops with "Failed dependencies". What did it change on the system?</summary>

Nothing. `rpm` refuses the whole transaction when a dependency is missing. `dnf install ./file.rpm` would fetch the missing dependency from a repository.
</details>

<details>
<summary>3. Which command tells you which package owns <code>/usr/bin/python3</code>?</summary>

`rpm -qf /usr/bin/python3`. It takes a file path and asks the installed database.
</details>

<details>
<summary>4. What does it mean when <code>rpm -V somepackage</code> prints nothing?</summary>

Every checked attribute of every file still matches what was recorded at install time. Silence is success.
</details>

<details>
<summary>5. <code>rpm -V</code> prints <code>S.5....T.  c /etc/app/app.conf</code>. Should you worry?</summary>

Usually not. The `c` marks a configuration file, and size, checksum and time changes on a configuration file mean someone edited it. The same codes on a program with no marker would be a real warning.
</details>

<details>
<summary>6. Why can a package's <code>--provides</code> list contain strings that are not its own name?</summary>

Dependencies are resolved by capability strings, not names. For example, `python3` provides `python(abi) = 3.9`, and other packages require that string.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-061
```
