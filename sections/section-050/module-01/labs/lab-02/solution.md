# Solution Walkthrough

## 1. See the two candidates

```bash
apt-cache policy curl
```

```text
curl:
  Installed: 8.5.0-2ubuntu10.6
  Candidate: 8.5.0-2ubuntu10.6
  Version table:
 *** 8.5.0-2ubuntu10.6 500
        500 http://.../ubuntu noble-updates/main amd64 Packages
     8.5.0-2ubuntu10   500
        500 http://.../ubuntu noble/main amd64 Packages
```

Both sources have priority `500`; the higher version (from `noble-updates`)
wins, so it is the Candidate.

## 2. Write the pin

```bash
sudo tee /etc/apt/preferences.d/pin-curl-release > /dev/null <<'EOF'
Package: curl
Pin: release a=noble
Pin-Priority: 990
EOF
```

- `Package: curl` — this pin applies only to `curl`.
- `Pin: release a=noble` — match the **archive** `noble` (the release
  pocket). `noble-updates` has `a=noble-updates`, so it is not matched.
- `Pin-Priority: 990` — above the default `500`, so the release-pocket
  version becomes preferred. `990` (not `1001`) means APT will not *force a
  downgrade* of the currently-installed updates version, but a future
  `apt upgrade` will not move `curl` past the release version either.

Priority reference: `< 0` never install · `500` default · `990` "install
this, and prefer it even if newer exists elsewhere" · `1001` also allow
downgrading to it.

## 3. Verify

```bash
sudo apt-get update
apt-cache policy curl
```

```text
curl:
  Installed: 8.5.0-2ubuntu10.6
  Candidate: 8.5.0-2ubuntu10
  Version table:
     8.5.0-2ubuntu10.6 500
        500 http://.../ubuntu noble-updates/main amd64 Packages
 *** 8.5.0-2ubuntu10   990
        990 http://.../ubuntu noble/main amd64 Packages
```

The `noble/main` line now shows `990` and the Candidate has flipped to the
release-pocket version. `apt-cache policy` is the tool that shows a pin
took effect.
