#!/bin/bash
set -ex

exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

export VERSION=1.23
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

yum install cri-o -y

systemctl daemon-reload
systemctl enable --now crio
systemctl start crio
