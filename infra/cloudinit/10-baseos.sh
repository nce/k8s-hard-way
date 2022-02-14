#!/bin/bash
set -xe

exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

yum -y install vim curl rsync
timedatectl set-timezone "Europe/Berlin"
