# Adding The Repository And Checking It

The vendor's key now sits in its own keyring file. Next comes the repository line itself: where it lives, how it names the key, and how to check that `apt` accepted it *before* you install anything. Along the way you meet the command that shows one package name coming from more than one depot at once.

## The repository line

A repository line tells `apt` the depot's address and which part of its catalogue to read. It goes in a small file of its own.

Save this as `/etc/apt/sources.list.d/vendor-nginx.list`:

```text
deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] https://vendor.example.com/nginx/ubuntu jammy main
```

Here is the line, field by field:

| Field | Meaning |
| --- | --- |
| `deb` | The depot ships binary packages (ready-built crates). |
| `[signed-by=...]` | Only the key in this keyring file may vouch for this depot. |
| `https://vendor.example.com/nginx/ubuntu` | The depot's base address. |
| `jammy` | The **suite**: which release's catalogue to read, often the Ubuntu codename. |
| `main` | The **component**: one section of that catalogue. |

The example uses `jammy`, the codename of Ubuntu 22.04. Ubuntu 24.04 is called `noble`, and a vendor may also pick its own suite name, so always copy the suite from the vendor's instructions.

Two placement facts matter:

- The line goes in its **own file** under `/etc/apt/sources.list.d/`. It does not go into the shared `/etc/apt/sources.list`, which holds Ubuntu's own depots. Removing the vendor later is then one `rm` of one file.
- Without `[signed-by=...]`, `apt` checks the depot against every key in the shared trusted set. That is exactly the loose, global model you want to avoid.

Newer Ubuntu releases also support the `deb822` format: a `.sources` file with several lines such as `Types:`, `URIs:` and `Signed-By:`. The one-line `.list` form above is still fully supported, and most exam tasks expect it.

## Check that `apt` accepted it

A repository file does nothing until `apt` reads it. Refreshing the catalogue is both the way to apply the file and the first check.

Apply it:

```sh
sudo apt update
```

`apt update` downloads the package index of every configured repository again, **including the new line**. If the key path or the `signed-by=` value is wrong, you see it here, not silently later. The usual messages are `NO_PUBKEY`, `signature verification failed` and `not signed`.

Then check the result:

```sh
apt-cache policy nginx
```

```text
nginx:
  Installed: (none)
  Candidate: 1.24.0-1~jammy
  Version table:
     1.24.0-1~jammy 500
        500 https://vendor.example.com/nginx/ubuntu jammy/main amd64 Packages
     1.24.0-2ubuntu7 500
        500 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
```

This is example output for the made-up vendor on an Ubuntu 22.04 (`jammy`) machine. On Ubuntu 24.04 the archive lines say `noble` and the version numbers differ, but the layout is the same. One detail in this example does not add up: both lines have priority `500`, so by the rule below Ubuntu's higher `1.24.0-2ubuntu7` would normally be the Candidate. Read the Candidate line here as an illustration and trust the rule.

## Reading `apt-cache policy`

The big idea in that output: **two repositories can each publish a package with exactly the same name.** Ubuntu's archive has its `nginx`, and the vendor has theirs. `apt-cache policy` is where you see both side by side.

- **`Installed:`** is the version on the ship now (`(none)` here).
- **`Candidate:`** is the version a plain `apt install` or `apt upgrade` would pick right now.
- **The version table** lists every version on offer, its **priority** and the exact depot and version string of each. The priority is the `500`. A higher priority wins; when priorities tie, the higher version wins.

Copy the version string you want from this output exactly. Installing an exact version needs it character for character.

## Common pitfalls

> [!WARNING]
> - **Adding the line to `/etc/apt/sources.list`** instead of a dedicated file under `sources.list.d/`. The vendor's settings are now mixed with Ubuntu's, and removing them is fiddly and easy to get wrong.
> - **Skipping `apt update` after adding the line.** `apt-cache policy` and every install still see the old catalogue, so the new depot's packages look missing.
> - **Ignoring an `apt update` warning** such as `NO_PUBKEY` or "InRelease is not signed". The depot is present but not trusted, so installs from it refuse or ask questions. Fix the key or the path now.
> - **Assuming one depot means one version.** The same name can point to Ubuntu's build or the vendor's build, depending on priority. Read the version table.
