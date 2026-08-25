# Question

Solve this question inside the `rpmbox` container. Get a shell with:
```bash
docker exec -it rpmbox bash
```

This lab is entirely read-only — do not install, remove, or upgrade anything. First, create the answers directory:
```bash
mkdir -p /home/candidate/answers
```

Then research the following, saving each answer into the exact file named below:

1. **Keyword search.** Find candidate packages related to intrusion-prevention/brute-force-blocking functionality without knowing the exact package name in advance. Save the full output of your search to `/home/candidate/answers/search.txt`.
2. **Full metadata, no install.** For the package `httpd`, pull its complete metadata (version, dependencies, description, installed size) without installing it. Save the full output to `/home/candidate/answers/info.txt`.
3. **What provides a missing command.** A colleague reports a script fails because the `ip` command isn't found. Determine which package would need to be installed to provide it, without installing anything yet, using dnf's file-to-package lookup rather than assuming a package name from memory. Save the full output to `/home/candidate/answers/provides.txt`.
4. **Installed package listing by pattern.** List every currently-installed package on the host whose name starts with `python3-`. Save the full output to `/home/candidate/answers/python-packages.txt`.
