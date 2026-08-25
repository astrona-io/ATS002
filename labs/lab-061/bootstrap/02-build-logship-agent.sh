#!/usr/bin/env bash
# Builds a small, REAL logship-agent-2.1.0-1 RPM inside rpmbox using
# rpmbuild against a real, trivial spec file, and stages the built package
# at /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm INSIDE the
# container -- exactly where docs/question.md tells the student to look.
# The package declares Requires on bash/coreutils, both already present in
# the base rockylinux:9 image, so a plain `rpm -ivh` from the student
# completes cleanly without needing dnf to resolve anything.

set -eu

echo "Installing rpm-build inside rpmbox..."
sudo docker exec rpmbox dnf -y install rpm-build

echo "Preparing the rpmbuild tree inside rpmbox..."
sudo docker exec rpmbox bash -c 'mkdir -p /root/rpmbuild/{SPECS,SOURCES,BUILD,RPMS,SRPMS,BUILDROOT}'

echo "Writing the logship-agent spec file inside rpmbox..."
sudo docker exec -i rpmbox bash -c 'cat > /root/rpmbuild/SPECS/logship-agent.spec' <<'SPEC'
Name:           logship-agent
Version:        2.1.0
Release:        1%{?dist}
Summary:        Internal log-shipping monitoring agent
License:        Proprietary
BuildArch:      x86_64
Requires:       bash, coreutils

%description
Internal monitoring / log-shipping agent used by the platform team. Not
published to any repository -- distributed as a standalone .rpm file only.

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/logship-agent
cat > %{buildroot}/usr/bin/logship-agent <<'SH'
#!/usr/bin/env bash
echo "logship-agent 2.1.0 -- stub monitoring agent"
SH
chmod 755 %{buildroot}/usr/bin/logship-agent
cat > %{buildroot}/etc/logship-agent/agent.conf <<'CFG'
# logship-agent configuration
server = log-collector.internal:9200
CFG

%files
/usr/bin/logship-agent
%config /etc/logship-agent/agent.conf

%changelog
* Mon Jan 01 2024 Astrona Labs <labs@astrona.io> - 2.1.0-1
- Initial internal build
SPEC

echo "Building the RPM with rpmbuild..."
sudo docker exec rpmbox rpmbuild --define "_topdir /root/rpmbuild" -bb /root/rpmbuild/SPECS/logship-agent.spec

echo "Staging the built RPM at /home/candidate/downloads/ inside rpmbox..."
sudo docker exec rpmbox mkdir -p /home/candidate/downloads
sudo docker exec rpmbox cp /root/rpmbuild/RPMS/x86_64/logship-agent-2.1.0-1.x86_64.rpm /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm

echo "Confirming the staged RPM is present..."
sudo docker exec rpmbox ls -l /home/candidate/downloads/logship-agent-2.1.0-1.x86_64.rpm

echo "logship-agent RPM staged. It is NOT installed yet -- that is the student's task."
