# Question

Solve this question on: `terminal`

Astronaut, mission control needs a short status report from this training ship. Three facts must be written into answer files in the folder `/opt/course`, which already exists and belongs to you.

Each file must hold **only the value**: no label, no `name = ` in front, no extra words.

1. Write the release of the running Linux kernel into `/opt/course/kernel`. This is the release string, not the build banner and not the full one-line summary.
2. Write the current live value of the kernel parameter `net.ipv4.ip_forward` into `/opt/course/ip_forward`. Report what the running kernel uses right now.
3. Write the system timezone into `/opt/course/timezone`, exactly as the system reports its configured timezone name.

The grader compares each file with the live state of the machine, so read the values from the system itself.
