#!/usr/bin/env bash
set -e
{
  timedatectl set-timezone Europe/Berlin

  yum -y remove cockpit*
  yum -y install vim curl rsync
} >> cloudinit.log
