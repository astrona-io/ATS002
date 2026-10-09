# Installed Versus Candidate

`apt show` describes a package in general. This part covers the commands that describe a package's link to *this* system right now: which version is installed, which one would be applied next, which repository it would come from, and how to list what is already on board by pattern.

## `apt-cache policy`: the view of this system

Ask about one package:

```bash
# shell: any host, unprivileged
apt-cache policy nginx
```

```text
nginx:
  Installed: (none)
  Candidate: 1.24.0-2ubuntu7
  Version table:
     1.24.0-2ubuntu7 500
        500 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
     1.24.0-1~jammy 500
        500 https://vendor.example.com/nginx/ubuntu jammy/main amd64 Packages
```

This example comes from an Ubuntu 22.04 (`jammy`) machine with a made-up vendor repository added. On Ubuntu 24.04 the archive line says `noble` and the versions differ.

Here is how to read it:

- **`Installed:`** is the version on the system now, or `(none)`.
- **`Candidate:`** is the version a plain `apt install` or `apt upgrade` would apply right now, given the current repository priorities. Unless the package is held, this is where the next upgrade goes.
- **The version table** lists every available version, its **priority** and the **exact repository and version string** of each. The priority is the `500`; a higher number wins, and when numbers tie the higher version wins. This is the only command that tells you *which repository* a candidate would come from. `apt show` never does.

Two repositories can both offer the same package name, for example Ubuntu's archive and a vendor's depot. Both appear here, and the priority column settles which one wins.

## List what is installed, by pattern

To see which packages of one family are on board, filter the installed list:

```bash
apt list --installed | grep '^python3-'
```

`apt list --installed` shows only installed packages, one per line, in the form `name/repo,now version arch [installed]`.

The **`^`** anchor in the `grep` matters. It matches only names that *begin with* the prefix, not any package whose name or version merely contains that text somewhere. `^python3-` gives a precise answer; plain `python3-` gives a noisy, half-wrong one.

The same subcommand answers "what is upgradable" as a report:

```bash
apt list --upgradable
```

Run it after `sudo apt update`, so the list reflects the current catalogue.

## When to trust `dpkg -s` instead

`apt show` and `apt-cache policy` describe APT's **cache** of repository metadata. That cache is only as accurate as the last `apt update`, and it describes the *candidate*. For "what is really installed on this system right now", the final word is the local `dpkg` database, the quartermaster's ledger:

```bash
dpkg -s nginx 2>/dev/null || echo 'nginx not installed'
```

`dpkg -s` reads that database directly, whatever the state of the cache. The tools work together: `apt show` and `apt-cache policy` answer "what is available"; `dpkg -s` answers "what is actually here". When the question is about installed state and an old cache could matter, trust `dpkg -s`.

## Common pitfalls

> [!WARNING]
> - **Expecting `apt show` to name the source repository.** It does not. `apt-cache policy` does, in the version table.
> - **Using `grep 'python3-'` without `^`.** It matches `libpython3-...`, names with `python3-` in the middle, and version strings. Anchor it.
> - **Trusting `apt-cache policy` on a system with an old index.** `Candidate:` reflects the last `apt update`. Run `apt update` first, or use `dpkg -s` for installed state.
> - **Feeding `apt list --installed` output straight to another command.** The `name/repo,...` format needs `cut -d/ -f1` first to leave only the names.

## Your mission: APT Package Information Lookup Lab

You can now search for a package, read its metadata, compare installed and candidate versions, and list packages by pattern, all without changing anything. The mission asks you to research five questions on one ship and save each answer to a file.

The mission runs on its own training ship. Start it and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-04/labs/lab-01
astrona ssh ats-002-lab-054
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-050/module-04/labs/lab-01
```

When the mission is done, remove it:

```sh
astrona destroy ats-002-lab-054
```
