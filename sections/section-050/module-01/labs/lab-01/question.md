# Question

Solve this question on: `terminal`

Your team needs a specific vendor build of `nginx` that isn't in Ubuntu's default archive. A "vendor" repository is already running on this VM, serving packages over plain HTTP at `http://127.0.0.1:8100` under the codename `vendor-nginx`, component `main`. The vendor's GPG public key is published at `http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc`.

1.  Import the vendor's GPG key the current, non-deprecated way — dearmor it into its own dedicated file under `/etc/apt/keyrings/` (do **not** use `apt-key`).
2.  Add the repository to APT using a `signed-by=` reference to that dedicated keyring, as its own file under `/etc/apt/sources.list.d/`. The repository line's suite/codename is `vendor-nginx` and its component is `main`.
3.  Refresh APT's index and confirm the repository registered — `apt-cache policy nginx` should now show a candidate from `127.0.0.1:8100` alongside anything Ubuntu's own archive offers.
4.  Install the **exact** version of `nginx` that the vendor repository publishes (copy the version string verbatim from `apt-cache policy nginx` — do not guess or retype it).
5.  Hold `nginx` at that version so a routine `apt upgrade`/`apt full-upgrade` cannot move it. Confirm the hold actually took.
