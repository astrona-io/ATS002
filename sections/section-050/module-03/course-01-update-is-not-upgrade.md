# Update Is Not Upgrade

Two commands one word apart do completely different things, and mixing them up is the most common mistake in this topic. This part settles what `apt update` actually touches (nothing you have installed), why skipping it makes every later command work from an old picture, and the read-only preview step.

## `apt update` refreshes the index, and only that

Run it first in every session:

```bash
# shell: host, root
sudo apt update
```

Say it once, out loud, so it is automatic under pressure: **`apt update` does not install, upgrade or remove a single package.**

What it does is download the **package index** again. The package index is the depot's catalogue: the list of what each repository offers right now, and at what version. `apt` fetches it from every source in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/*`, and it checks each catalogue's signature on the way.

Picture `apt update` as downloading each depot's latest catalogue to the ship. It brings no crates on board. The catch is that an old catalogue looks exactly like a fresh one, until an install fails or an available fix is missed.

If you skip it:

- `apt upgrade` can miss an update that is really available.
- `apt install newpkg` can fail to find a package published minutes ago.
- `apt-cache policy` shows yesterday's candidate versions.

## Preview what would change

Before applying anything, ask a read-only question:

```bash
apt list --upgradable
```

```text
Listing...
curl/jammy-updates 7.81.0-1ubuntu1.15 amd64 [upgradable from: 7.81.0-1ubuntu1.13]
openssl/jammy-security 3.0.2-0ubuntu1.12 amd64 [upgradable from: 3.0.2-0ubuntu1.10]
```

This example output comes from an Ubuntu 22.04 (`jammy`) machine. On Ubuntu 24.04 the pockets read `noble-updates` and `noble-security`, and the versions differ.

The command lists every installed package that has a newer candidate available. Each line shows the name, the new candidate version, and in brackets the version installed now. Nothing changes: it is a report. Run it after `apt update` and before `apt upgrade` to see exactly what is about to move.

## Common pitfalls

> [!WARNING]
> - **Taking `apt update` for `apt upgrade`.** `update` never changes installed software; `upgrade` does. They are different operations.
> - **Running `apt install` or `apt upgrade` without a recent `apt update`.** Decisions are made from an old catalogue, so a package or fix that really exists can look missing.
> - **Reading `apt list --upgradable` as an action.** It changes nothing; it is only the preview.
