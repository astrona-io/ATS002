# Question

Solve this question on: `terminal`

Install the text-based terminal web browser `links` from source on this server.

The source is provided at `/tools/links-2.14.tar.bz2` on this server.

Configure the build so that:

1. The installed binary is at exactly `/usr/bin/links`, and `which links` finds it there.
2. Support for IPv6 is disabled.

The grader checks that `/usr/bin/links` is a compiled program (not a script), that it reports version `2.14`, and that `links -version` shows IPv6 as disabled.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms links is installed at /usr/bin/links, is a real compiled ELF binary, and was built with ipv6 support disabled.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
