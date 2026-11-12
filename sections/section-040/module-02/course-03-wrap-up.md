# Review and cleanup

The [label exercise](course-01-contexts-and-restorecon.md) separates a live label from its persistent rule. The [port and boolean exercise](course-02-booleans-ports-and-reading-denials.md) connects denials to the operation the service needs. The [lab](labs/lab-01/question.md) combines these changes and verifies them with HTTP requests after reboot.

Explain why `chcon` alone can be undone, why `setsebool` needs `-P`, and why a direct backend request does not prove Apache can reach it.

When finished, remove the remaining environment:

```sh
astrona destroy selinux-commands-bay
```

<!-- astrona:playground:destroy -->
