# Question

Solve this question on: `terminal`

Astronaut, your team needs a vendor's own build of `nginx` that Ubuntu's archive does not carry. The vendor's supply depot (an APT repository) is already running on this ship. It serves packages over plain HTTP at `http://127.0.0.1:8100`, under the suite (codename) `vendor-nginx` and the component `main`. The vendor's GPG public key (its signing key, in ASCII-armored text form) is published at `http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc`.

1. Import the vendor's key the current, non-deprecated way: convert it with `gpg --dearmor` into its own dedicated keyring file under `/etc/apt/keyrings/`, with a name ending in `.gpg`. Do **not** use `apt-key`.
2. Add the repository to APT as its own `.list` file under `/etc/apt/sources.list.d/`. The repository line must use `signed-by=` to point at the keyring file from step 1. Its suite is `vendor-nginx` and its component is `main`.
3. Refresh APT's package index and check that the repository registered: `apt-cache policy nginx` should now show a version from `127.0.0.1:8100` next to anything Ubuntu's own archive offers.
4. Install the **exact** version of `nginx` that the vendor repository publishes. Copy the version string from `apt-cache policy nginx`; do not guess or retype it.
5. Hold `nginx` at that version so a routine `apt upgrade` or `apt full-upgrade` cannot move it, and confirm that the hold took.

The grader checks that a `.list` file under `/etc/apt/sources.list.d/` contains `signed-by=/etc/apt/keyrings/<name>.gpg` and that this keyring file exists and is a valid GPG keyring, that `nginx` is fully installed at exactly the vendor's version, and that `apt-mark showhold` lists `nginx`.
