# Pin curl to the release pocket

Inspect the installed and candidate versions with `apt-cache policy curl`. Find the repository entry whose archive is `noble`, then write a package-specific preference:

```sh
sudo tee /etc/apt/preferences.d/pin-curl-release >/dev/null <<'EOF'
Package: curl
Pin: release a=noble
Pin-Priority: 1001
EOF
sudo apt-get update
apt-cache policy curl
```

The task asks for the release version to become the candidate even when a newer updates version is installed. Priority 1001 permits that downgrade decision. A priority of 990 does not force APT to prefer an older version over an installed newer version. Writing the preference does not install or downgrade a package by itself.

Confirm that the release-pocket entry has priority 1001 and that its version matches the candidate. Keep the pin scoped to `curl`; other packages should retain their usual update policy.

Submit after checking the result:

```sh
astrona submit -c sections/section-050/module-01/labs/lab-02
```

Reference: [APT preference rules](https://manpages.debian.org/trixie/apt/apt_preferences.5.en.html).
