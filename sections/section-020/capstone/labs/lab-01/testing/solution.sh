#!/usr/bin/env bash
set -euo pipefail
sudo docker rm -f billing_v1
sudo docker run -d --name billing_v2 --memory=64m -p 9090:80 nginx:alpine
sudo usermod -aG docker ops-monitor
sudo mkdir -p /home/ops-monitor
sudo tee /home/ops-monitor/watch-billing.sh >/dev/null <<'REFERENCE_FILE'
#!/usr/bin/env bash
if [ "$(docker inspect -f '{{ .State.Running }}' billing_v2)" != true ]; then docker start billing_v2; fi
REFERENCE_FILE
sudo chmod 755 /home/ops-monitor/watch-billing.sh
sudo chown ops-monitor:ops-monitor /home/ops-monitor/watch-billing.sh
printf '%s
' '* * * * * bash /home/ops-monitor/watch-billing.sh' | sudo crontab -u ops-monitor -
