#!/usr/bin/env bash
set -exuo pipefail

yum -y update
yum -y install vim curl rsync conntrack ipset policycoreutils-python-utils
timedatectl set-timezone "Europe/Berlin"
