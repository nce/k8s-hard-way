#!/bin/bash
set -xe

yum -y install vim curl rsync
adduser kubernetes
adduser etcd
timedatectl set-timezone "Europe/Berlin"
