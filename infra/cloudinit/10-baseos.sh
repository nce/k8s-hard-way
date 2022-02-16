#!/bin/bash
set -xe

yum -y install vim curl rsync
adduser kubernetes
timedatectl set-timezone "Europe/Berlin"
