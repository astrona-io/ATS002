# Question

Solve this question on: `terminal`

Astronaut, before anyone changes this ship, mission control wants five research answers. Nothing in this lab should be installed, removed or upgraded: every task is read-only. Save each answer into the given file under `/opt/course/apt-research/` (already created for you and owned by your user), using the exact output of the command described.

1. Find packages related to `fail2ban`-style intrusion prevention without assuming you know the exact package name: search by keyword. Save the full search output to `/opt/course/apt-research/fail2ban-search.txt`.
2. For the package `nginx`, get its complete metadata (version, dependencies, description, installed size) without installing it. Save the full output to `/opt/course/apt-research/nginx-show.txt`.
3. For `nginx`, show whether it is installed, which version is installed (if any) compared with the candidate version, and which configured repository that candidate would come from. Save the full output to `/opt/course/apt-research/nginx-policy.txt`.
4. List every installed package on this host whose name starts with `python3-`. Save the list to `/opt/course/apt-research/python3-installed.txt`.
5. List everything on this host that is upgradable right now. Save the list to `/opt/course/apt-research/upgradable.txt`.

The grader checks that `fail2ban-search.txt` has a line starting with `fail2ban/`; that `nginx-show.txt` has a `Package: nginx` line and a `Version:` equal to the live candidate version; that `nginx-policy.txt` has `Installed:` and `Candidate:` lines matching the live `apt-cache policy nginx`; that the package names in `python3-installed.txt` match the live set of installed `python3-*` packages; and that the package names in `upgradable.txt` match the live `apt list --upgradable` output.
