# Question

Solve this question on: `terminal`

Before making any changes, you've been asked to research five things. Nothing in this lab should be installed, removed, or upgraded — every task below is read-only. Record each answer into the given file under `/opt/course/apt-research/` (already created for you), using the exact output of the command described.

1.  Find candidate packages related to `fail2ban`-style intrusion prevention without assuming you know the exact package name in advance — search by keyword. Save the full search output to `/opt/course/apt-research/fail2ban-search.txt`.
2.  For the package `nginx`, pull its complete metadata (version, dependencies, description, installed size) without installing it. Save the full output to `/opt/course/apt-research/nginx-show.txt`.
3.  For `nginx` specifically, confirm whether it's currently installed, what version is installed (if any) versus what version is available as a candidate, and which configured repository that candidate would come from. Save the full output to `/opt/course/apt-research/nginx-policy.txt`.
4.  List every currently-installed package on this host whose name starts with `python3-`. Save the list to `/opt/course/apt-research/python3-installed.txt`.
5.  List everything on this host that's currently upgradable. Save the list to `/opt/course/apt-research/upgradable.txt`.
