# SELinux: contexts, booleans and ports

A web service can have readable files and still be refused access by SELinux. SELinux checks security labels on processes, files and ports. This module uses Rocky Linux with enforcement enabled so you can observe the refusal and repair its cause.

## Learning objectives

Read process and file contexts, inspect audit denials, and make persistent file, boolean and port changes. Verify the service through real requests and a reboot.

## Before you start

You need a working shell and `sudo`. The playground contains Apache, a page at `/srv/web`, and a local backend. The service starts with three policy faults. Its x86_64 image is pinned by SHA-256. ARM hosts use slower emulation; image downloads and package installation add startup time.

<!-- astrona:playground -->

## Reading order

1. [Contexts and restorecon](course-01-contexts-and-restorecon.md)
2. [Booleans, ports and denials](course-02-booleans-ports-and-reading-denials.md)
3. [Service repair lab](labs/lab-01/question.md)
4. [Review](course-03-wrap-up.md)
