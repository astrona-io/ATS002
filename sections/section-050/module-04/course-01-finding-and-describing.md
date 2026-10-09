# Finding And Describing A Package

Before you commit to any change, there is a read-only layer of `apt` tools whose only job is to answer questions. This part covers finding a package when you only have a rough idea of it, and reading everything its metadata declares, without touching the system.

## `apt search`: a keyword in the name *and* the description

A task often describes what a package *does*, not its name: "something that blocks repeated failed SSH logins", not "install fail2ban". Search the depots' catalogue by keyword:

```bash
# shell: any host, unprivileged
apt search fail2ban
```

`apt search` (a friendly front end for `apt-cache search`) matches the keyword against both package **names** and their **description text**, ignoring upper and lower case. That is the point: it finds the right package even when your keyword is not in the name, which is exactly when you do not yet know what to type into `apt install`.

When you already know roughly how the name is spelled, use a narrower, **name-only** match:

```bash
apt list 'fail2ban*' 2>/dev/null
```

`apt list` with a shell **glob** (a wildcard pattern such as `fail2ban*`) matches package names only. The `2>/dev/null` hides `apt`'s warning that its output format may change between versions. Keep the two apart: `search` means "I do not know the exact name"; `list <pattern>` means "I know roughly how it is spelled".

## `apt show`: the full declared metadata

Once you have a name, read the crate's label:

```bash
apt show nginx
```

`apt show` prints everything the package's control record declares: version, maintainer, the `Depends:`, `Recommends:` and `Suggests:` lines, the long description, the installed size and the download size. It only reads APT's **local index cache**, the catalogue on your ship, so it changes nothing.

Review a package's dependencies and size here before you recommend or approve an install. It costs nothing and catches problems early.

`apt show` describes the package **in general**. It does not tell you what is installed on *this* system, or which repository a version would come from. `apt-cache policy` and `dpkg -s` answer those questions.

## Common pitfalls

> [!WARNING]
> - **Using `apt show <exact-name>` to discover a package.** It only matches an exact name. Use `apt search <keyword>` when you do not know the name.
> - **Running `apt list` without a pattern.** It lists almost everything. Give it a glob (`'php8.1-*'`) or `--installed`.
> - **Reading `apt show` as the installed state.** It reports the cached candidate's metadata, not what is on the machine. Use `dpkg -s` for that.
> - **Forgetting the cache can be old.** `apt show` is only as fresh as the last `apt update`.
