#!/usr/bin/env bash
# Builds a small, REAL metrics-shipper-1.4.0-1 RPM inside rpmbox using
# rpmbuild against a real, trivial spec file (same technique as
# lab-061/bootstrap/02-build-logship-agent.sh), and stages the built
# package at /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm
# INSIDE the container. The package declares Requires on bash/coreutils,
# both already present in the base rockylinux:9 image, so a plain
# `rpm -ivh` completes cleanly once the RPM database itself is healthy --
# this script runs BEFORE the database gets deliberately corrupted in
# 03-corrupt-rpmdb.sh, mirroring a package genuinely staged before an
# unrelated overnight incident.

set -eu

echo "Installing rpm-build inside rpmbox..."
sudo docker exec rpmbox dnf -y install rpm-build

echo "Preparing the rpmbuild tree inside rpmbox..."
sudo docker exec rpmbox bash -c 'mkdir -p /root/rpmbuild/{SPECS,SOURCES,BUILD,RPMS,SRPMS,BUILDROOT}'

echo "Writing the metrics-shipper spec file inside rpmbox..."
sudo docker exec -i rpmbox bash -c 'cat > /root/rpmbuild/SPECS/metrics-shipper.spec' <<'SPEC'
Name:           metrics-shipper
Version:        1.4.0
Release:        1%{?dist}
Summary:        Internal metrics-shipping monitoring agent
License:        Proprietary
BuildArch:      x86_64
Requires:       bash, coreutils

%description
Internal monitoring / metrics-shipping agent used by the platform team.
Not published to any repository -- distributed as a standalone .rpm file
only.

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/metrics-shipper
cat > %{buildroot}/usr/bin/metrics-shipper <<'SH'
#!/usr/bin/env bash
echo "metrics-shipper 1.4.0 -- stub monitoring agent"
SH
chmod 755 %{buildroot}/usr/bin/metrics-shipper
cat > %{buildroot}/etc/metrics-shipper/agent.conf <<'CFG'
# metrics-shipper configuration
server = metrics-collector.internal:9201
CFG

%files
/usr/bin/metrics-shipper
%config /etc/metrics-shipper/agent.conf

%changelog
* Mon Jan 01 2024 Astrona Labs <labs@astrona.io> - 1.4.0-1
- Initial internal build
SPEC

echo "Building the RPM with rpmbuild..."
sudo docker exec rpmbox rpmbuild --define "_topdir /root/rpmbuild" -bb /root/rpmbuild/SPECS/metrics-shipper.spec

echo "Staging the built RPM at /home/candidate/downloads/ inside rpmbox..."
sudo docker exec rpmbox mkdir -p /home/candidate/downloads
sudo docker exec rpmbox cp /root/rpmbuild/RPMS/x86_64/metrics-shipper-1.4.0-1.x86_64.rpm /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm

echo "Confirming the staged RPM is present..."
sudo docker exec rpmbox ls -l /home/candidate/downloads/metrics-shipper-1.4.0-1.x86_64.rpm

echo "metrics-shipper RPM staged. It is NOT installed yet -- that is part of the student's task."
