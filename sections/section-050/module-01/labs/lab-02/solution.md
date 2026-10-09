# Solution Walkthrough

Three steps: look at the two versions, write the pin, then check that the Candidate moved. Run `astrona submit` at the end to confirm.

## 1. See the two versions

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

The repository addresses are shortened to `http://.../ubuntu`. Both sources have priority `500`, so the higher version (from `noble-updates`) wins and is the Candidate. The `***` marks the version that is installed now.

## 2. Write the pin

Save this as `/etc/apt/preferences.d/pin-curl-release`:

```text
Package: curl
Pin: release a=noble
Pin-Priority: 990
```

Here is what each line does:

- `Package: curl` makes this pin apply only to `curl`.
- `Pin: release a=noble` matches the **archive** `noble`, that is the release pocket. `noble-updates` has `a=noble-updates`, so it does not match.
- `Pin-Priority: 990` is above the default `500`, so the release-pocket version becomes the preferred one. A value of `990` (not `1001`) means APT will not *force a downgrade* of the installed updates version, but a future `apt upgrade` will not move `curl` past the release version either.

Priority reference: below `0` never install; `500` is the default; `990` means "install this, and prefer it even if a newer version exists elsewhere"; `1001` also allows a downgrade to it.

## 3. Check

Apply it:

```bash
sudo apt-get update
```

Then check the result:

```bash
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

The `noble/main` line now shows `990`, and the Candidate has moved to the release-pocket version. `apt-cache policy` is the tool that shows a pin took effect.

One detail in this recorded output looks off: `***` should still mark the installed `8.5.0-2ubuntu10.6`, because the pin installs nothing. Also, APT normally does not pick a version older than the installed one as Candidate unless the priority is `1000` or more. If your Candidate still shows the updates version, check the installed version with `apt-cache policy curl` and consider a priority of `1001`; the grader accepts any priority above `500`.

When the Candidate comes from `noble/main`, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-01/labs/lab-02
```
