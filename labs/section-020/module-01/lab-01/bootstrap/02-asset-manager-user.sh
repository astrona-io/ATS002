#!/usr/bin/env bash
# Bootstrap: creates the asset-manager service account and the two scripts
# its cron jobs reference (nightly-sync.sh for the pre-existing system-wide
# job, clean.sh for the new job the scenario asks for), so the starting
# state is self-consistent before any cron entry references them.

set -eu

if ! id asset-manager >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash asset-manager
fi

sudo tee /home/asset-manager/nightly-sync.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
# Placeholder nightly data sync job for asset-manager.
echo "$(date -Iseconds) nightly-sync ran" >> /home/asset-manager/nightly-sync.log
EOF

sudo tee /home/asset-manager/clean.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
# Placeholder cleanup job for asset-manager.
echo "$(date -Iseconds) clean ran" >> /home/asset-manager/clean.log
EOF

sudo chmod 755 /home/asset-manager/nightly-sync.sh /home/asset-manager/clean.sh
sudo chown asset-manager:asset-manager /home/asset-manager/nightly-sync.sh /home/asset-manager/clean.sh
