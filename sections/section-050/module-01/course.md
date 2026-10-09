# Third-Party Repositories & Package Pinning

Astronaut, a **package** is a supply crate: it carries a piece of software, a parts list, a version number and the names of the other crates it needs. Your ship gets its crates from **repositories**, the supply depots. Ubuntu runs a huge depot of its own, but sooner or later you need a crate it does not stock: a newer release, a vendor's own build, or software Ubuntu never packed at all.

The fix always has the same shape. You teach `apt`, the ship's quartermaster, about a depot Ubuntu does not control. You say exactly which wax seal (signing key) you trust for that depot, and exactly which version of the crate you want. Then you make sure routine maintenance does not quietly swap the crate for another one. This module does that from start to finish.

## Learning objectives

After this module you can:

- Explain why the `signed-by=` option trusts a key for less than `apt-key add` does.
- Import a vendor's signing key into its own keyring file with `gpg --dearmor`, and point a repository line at it.
- Add a third-party repository in its own file under `/etc/apt/sources.list.d/`, and check that `apt` accepts and trusts it.
- Read `apt-cache policy` output: the Installed line, the Candidate line, the priorities, and a version table where one package name comes from several depots.
- Install an exact version with the `=version` form, copied character for character from the version table.
- Hold a package with `apt-mark hold`, check it with `apt-mark showhold`, and tell a hold apart from a pin and from switching off a repository.

## Before you start

Check that you have the knowledge and the tools this module expects before you begin.

### What you should already know

- **How to run a command with `sudo`.** Many commands here change the system, so they need the captain's authority.
- **That `apt install` gets software from configured repositories.** You do not need to know how yet.
- **A little about `curl`.** It downloads a file from an address. Knowing GPG (the tool that handles signing keys) helps, but every key step is shown.

### What you need

- A terminal on an Ubuntu 24.04 machine. The examples in the parts use a made-up vendor address (`vendor.example.com`), so read them as patterns; the missions give you a real local repository to work against.
- Or a running lab machine: start a mission with `astrona run` and open a terminal on it with `astrona ssh <lab name>`. Each mission gives you the exact commands.

## How this module is laid out

1. [Scoped Trust With Keyrings And signed-by](./course-01-scoped-trust.md): why `apt-key add` is deprecated, the per-vendor keyring under `/etc/apt/keyrings/`, `gpg --dearmor`, and the `signed-by=` option that ties a key to one repository.
2. [Adding The Repository And Checking It](./course-02-adding-the-repository.md): the `deb [signed-by=...]` line in its own file, `apt update` as the check, and reading `apt-cache policy` when two depots offer the same package name.
3. [Installing An Exact Version And Holding It](./course-03-exact-version-and-hold.md): the `=version` form, `apt-mark hold` and `showhold`, and how a hold differs from APT pinning and from switching off the repository.
   - Mission: Third-Party Repositories & Package Pinning Lab
   - Mission: APT Pinning (not a hold) Lab
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md)

## Why this matters

A server that pulls a crate from the wrong depot, or lets a routine upgrade swap a carefully chosen version, breaks quietly. Nothing fails at install time. The trouble shows up weeks later, and nobody remembers why the version changed. Scoped trust, exact versions and a checked hold keep the ship exactly as predictable as it was yesterday.
