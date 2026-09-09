# Question

**Work inside the `zypperbox` container for this entire lab.** Shell in first:

```bash
docker exec -it zypperbox bash
```

Every zypper command below runs inside that shell — the Ubuntu host itself has no zypper installed.

You are running a routine maintenance pass on an openSUSE Leap 15.6 host (the `zypperbox` container). This host follows a conservative, security-focused update policy: apply curated security patches promptly, but do not chase every routine package version bump.

1. Refresh the repository metadata.
2. Report what raw package updates are currently available, and separately, what curated patches are currently available — these are two different questions, and the policy review needs both answered before anything is applied.
3. Per the host's conservative policy, apply only the available patches — not a full package update.
4. Install the `fail2ban` package, newly required per policy.
5. The `telnet-server` package (which provides the `telnetd` daemon) is no longer needed anywhere on this host — remove it. It lives in the `network-utilities` repository, which bootstrap has already added and enabled for you.
6. Review zypper's own operation history to confirm exactly what was done during this maintenance window, and in what order.
