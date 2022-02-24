#!/usr/bin/env bash
set -xeuo pipefail

yum -y install vim curl rsync socat conntrack ipset
timedatectl set-timezone "Europe/Berlin"
