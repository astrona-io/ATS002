# Question

Solve this question on: `terminal`, inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error on the lab machine, run the same command with `sudo` in front.

Astronaut, this mission is entirely read-only: do not install, remove or upgrade anything. First, create the answers directory:
```bash
mkdir -p /home/candidate/answers
```

Then research the following, and save each answer into the exact file named below:

1. **Keyword search.** Find candidate packages for blocking brute-force login attempts (intrusion prevention) without knowing the exact package name in advance. Save the full output of your search to `/home/candidate/answers/search.txt`. The saved output must mention the `fail2ban` package.
2. **Full details, no install.** For the package `httpd`, pull its complete details (version, description, size and so on) without installing it. Save the full output to `/home/candidate/answers/info.txt`. It must contain the `Name` and `Version` fields, and `httpd` must still not be installed afterwards.
3. **What provides a missing command.** A colleague reports that a script fails because the `ip` command is not found. Find which package would need to be installed to provide it, without installing anything yet. Use `dnf`'s file-to-package lookup rather than a package name from memory. Save the full output to `/home/candidate/answers/provides.txt`. It must name the package and show the matching path ending in `/ip`.
4. **Installed packages by pattern.** List every installed package whose name starts with `python3-`. Save the full output to `/home/candidate/answers/python-packages.txt`, with one package per line as `dnf` prints it (each line starts with the package name). Every installed `python3-` package must be in the list.

The grader reads the four files inside `rpmbox` and checks that `httpd` is not installed.
