#!/bin/bash
set -ex

curl -O "https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz"

tar -xvf etcd-v${etcd_version}-linux-amd64.tar.gz
mv etcd-v${etcd_version}-linux-amd64/etcd* /usr/local/bin/

mkdir -p /etc/etcd /var/lib/etcd
chmod 700 /var/lib/etcd
cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

ETCD_NAME=$(hostname -s)
cat <<EOF | sed "s/ETC_NAME/$(hostname -s)/" | sed "s/INTERNAL_IP/$(hostname -i)/" | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ETC_NAME \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \\
  --listen-peer-urls https://INTERNAL_IP:2380 \\
  --listen-client-urls https://INTERNAL_IP:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://INTERNAL_IP:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
