# Question

Solve this question on: `terminal`, inside the `zypperbox` container

**Work inside the `zypperbox` container for this entire lab.** Open a shell in it first:

```bash
docker exec -it zypperbox bash
```

Every `zypper` command below runs inside that shell. The Ubuntu host itself has no `zypper` installed.

You are running a routine maintenance pass on an openSUSE Leap 15.6 host (the `zypperbox` container). This host follows a conservative, security-focused update policy: apply reviewed security patches promptly, but do not chase every routine package version bump.

1. Refresh the repository metadata.
2. Report which raw package updates are currently available and, separately, which patches are currently available. These are two different questions, and the policy review needs both answered before anything is applied.
3. Following the host's conservative policy, apply only the available patches, not a full package update.
4. Install the `fail2ban` package, which the policy now requires.
5. The `telnet-server` package (it provides the `telnetd` daemon) is no longer needed anywhere on this host. Remove it. It comes from the `network-utilities` repository, which is already added and enabled for you.
6. Review `zypper`'s own operation history to confirm exactly what was done during this maintenance window, and in what order.

Use `zypper` for the install and the removal, so that its history log records both. The grader checks that `fail2ban` is installed, that `telnet-server` is not installed, and that `/var/log/zypp/history` holds an `install` entry for `fail2ban` and a `remove` entry for `telnet-server`.
