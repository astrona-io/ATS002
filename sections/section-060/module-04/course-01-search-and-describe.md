# Finding and Describing a Package

Astronaut, before you order a crate you look it up in the depot's catalogue. This part is entirely read-only: you find a package by keyword and then read its full details. Nothing is installed, removed or upgraded.

## Searching the catalogue

`dnf` keeps a local copy of each repository's catalogue, the **package index**. All three commands below read that copy; none of them changes the ship.

### dnf search: keyword across name and summary

You have a rough idea, not a name: "something that blocks brute-force login attempts".

```bash
# shell: inside the rpmbox container
dnf search fail2ban
```

`dnf search` matches the keyword against package **names** and their one-line **summary**, so it finds hits even when the keyword is not part of the name.

### dnf search all: also the long description

For a wider net that also searches the longer description:

```bash
dnf search all fail2ban
```

Use `search all` when a plain search comes up empty.

### dnf list available: name only

If you already know roughly how the name is spelled and want a narrower, name-only match:

```bash
dnf list available 'fail2ban*'
```

Keep the two ideas apart: `search` means "I do not know the name"; `list available '<glob>'` means "I know roughly how it is spelled". The quotes stop the shell from expanding the `*` against files in your current directory.

## Reading one package's details

Once you have a name, read everything the catalogue says about it before you install it.

### dnf info

```bash
dnf info httpd
```

This prints the version, release, architecture, size, **source repository**, license and a long description. It all comes from `dnf`'s copy of the repository catalogue. It installs and changes nothing. It plays the same role as `apt show` on Debian, or `rpm -qip` for a single `.rpm` file, and it is the step to run before you recommend or approve any install.

`dnf info` is only as fresh as the last catalogue refresh. `dnf --refresh info <pkg>` forces a refresh first. For deeper or scripted research, `dnf repoquery` asks the same catalogue with many more options.

## Common pitfalls

> [!WARNING]
> - **Using `dnf info <exact-name>` to discover a package.** It only matches an exact name. Use `dnf search <keyword>` to discover.
> - **Mixing up `dnf search` and `dnf search all`.** Plain `search` covers name and summary; `search all` adds the long description.
> - **Reading `dnf info` as installed state.** It shows the repository catalogue's view, not what is on the ship. `rpm -qi` shows what is installed.
> - **Trusting an out-of-date catalogue.** `dnf info` is only as fresh as the last refresh; `dnf --refresh info <pkg>` forces one.
