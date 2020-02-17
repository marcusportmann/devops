#!/bin/sh

sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r)

mkdir -p /mnt/cdrom

mount /home/cloud-user/VBoxGuestAdditions_6.1.2.iso /mnt/cdrom -o loop

/mnt/cdrom/VBoxLinuxAdditions.run --nox11




