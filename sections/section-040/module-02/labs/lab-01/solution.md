# Repair the service policy

Inspect the failed service and recent denials first:

```sh
sudo journalctl -u httpd -n 30 --no-pager
sudo ausearch -m AVC -ts recent
getenforce
```

The service needs permission to bind its port, read its document root, and open a connection to its backend. Apply those three changes:

```sh
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'
sudo restorecon -Rv /srv/web
sudo semanage port -a -t http_port_t -p tcp 8888
sudo setsebool -P httpd_can_network_connect on
sudo systemctl restart httpd
```

Check both paths while enforcement remains enabled:

```sh
getenforce
ps -eZ | grep httpd
curl --fail http://127.0.0.1:8888/
curl --fail http://127.0.0.1:8888/probe
```

A successful direct request to port 19090 only proves the backend is up. The request through port 8888 proves the confined Apache process can reach it. Reboot with `sudo reboot`, reconnect, and repeat the checks to prove persistence.
