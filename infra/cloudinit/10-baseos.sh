#!/bin/bash
set -xe

yum -y install vim curl rsync socat conntrack ipset
adduser kubernetes
timedatectl set-timezone "Europe/Berlin"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
  br_netfilter
  overlay
EOF

modprobe br_netfilter
modprobe overlay

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward                 = 1
  net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

swapoff -a


