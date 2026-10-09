# Question

Solve this question on: `terminal`

Astronaut, on this ship `apt-cache policy curl` shows two versions of `curl`: a lower one from Ubuntu's `noble` **release** pocket, and a higher one from `noble-updates`. A pocket is one part of Ubuntu's depot: `noble` holds the versions the release shipped with, and `noble-updates` holds later fixes. By default APT prefers the higher `noble-updates` version.

Your team wants APT to prefer the **release-pocket** version of `curl`. Use APT's **pinning** mechanism (a file under `/etc/apt/preferences.d/`), not `apt-mark hold`. A hold only freezes whatever is installed; a pin changes which version APT *prefers* as the Candidate, and that is what is wanted here.

1. Create a file under `/etc/apt/preferences.d/` that pins `curl` (`Package: curl`) to the `noble` release pocket (`Pin: release a=noble`) with a `Pin-Priority:` above `500`, so it beats the default priority of the updates pocket.
2. Run `apt-get update`, then check with `apt-cache policy curl` that the **Candidate** is now the release-pocket version, coming from `.../noble/main` and not from `noble-updates`.

Do not use `apt-mark hold`, and do not switch off the `noble-updates` repository.

The grader checks that a file under `/etc/apt/preferences.d/` contains `Package: curl`, a `Pin: release a=noble` line and a `Pin-Priority:` greater than `500`, and that the Candidate in `apt-cache policy curl` comes from `noble/main`, not from `noble-updates` or `noble-security`.
