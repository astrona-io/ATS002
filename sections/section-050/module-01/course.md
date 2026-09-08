# Chapter 1: Third-Party Repositories & Package Pinning

Ubuntu's archive is huge but finite. Eventually you need a vendor's own build of some software — a newer release, a differently-compiled one, or something the distro never packaged. The fix is always the same shape: teach `apt` about a repository the distro does not control, be precise about exactly which key you trust and exactly which version you keep, and make sure routine maintenance does not quietly move it. This module does that end to end.

Three short parts; work them in order.

## How this module is organised

1. **[Part 1 — Scoped trust: keyrings and `signed-by`](./course-01-scoped-trust.md)** — why `apt-key add` is deprecated (global blast radius), the per-vendor keyring under `/etc/apt/keyrings/`, `gpg --dearmor`, and the `signed-by=` option that scopes a key to one repository.
2. **[Part 2 — Adding the repository and confirming it registered](./course-02-adding-the-repository.md)** — the `deb [signed-by=…] …` line in its own file under `/etc/apt/sources.list.d/`, `apt update` as the verification step, and reading `apt-cache policy` when two repositories offer the same package name.
3. **[Part 3 — Installing an exact version, and locking it](./course-03-exact-version-and-hold.md)** — APT's `=version` exact-match syntax, `apt-mark hold` / `showhold`, and the difference between a hold, APT pinning, and disabling the repository.

## Learning objectives

After this module you can:

- **Explain** why `signed-by=` is a narrower trust model than `apt-key add`.
- **Import** a vendor GPG key into a dedicated keyring with `gpg --dearmor`, and reference it from a repository line.
- **Add** a third-party repository in its own `.list` file and verify `apt` accepted and trusts it.
- **Read** `apt-cache policy` output — Installed, Candidate, priorities, and a version table with multiple sources for one name.
- **Install** an exact version with `=version` syntax, copied verbatim from the version table.
- **Hold** a package with `apt-mark hold`, verify it with `apt-mark showhold`, and distinguish a hold from a pin and from disabling the repository.

## Before you start

Assumed: a Linux shell, `sudo`, `curl`, and the idea that `apt` installs from configured repositories. GPG familiarity helps but the key steps are shown. Every command block states the shell and privilege it assumes; the examples use placeholder vendor URLs.

## Where this fits

This is the first Debian package-management module and the one about *trust and precision* — everything after it (dpkg internals, the daily `apt` loop, information lookup, bulk operations) assumes you can reason about where a package came from and which version is installed. The `apt-cache policy` habit from Part 2 recurs in every later module.
