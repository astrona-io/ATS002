# Question

Solve this question on: `terminal`

`apt-cache policy curl` on this host shows two candidates: a lower version
from the `noble` **release** pocket, and a higher one from `noble-updates`.
By default APT prefers the `-updates` version.

Your team needs `curl` held at the **release-pocket** version — but with
APT's **pinning** mechanism (`/etc/apt/preferences.d/`), not `apt-mark
hold`. A hold just freezes whatever is installed; a pin changes which
version APT *prefers* as the candidate, which is what is wanted here.

1. Create a file under `/etc/apt/preferences.d/` that pins `curl` to the
   `noble` release pocket (`Pin: release a=noble`) at a priority high
   enough to beat the default `500` of the updates pocket.
2. Run `apt-get update`, then confirm with `apt-cache policy curl` that the
   **Candidate** is now the release-pocket version, sourced from
   `.../noble/main` — not `noble-updates`.

Do not use `apt-mark hold`, and do not disable the `noble-updates`
repository.
