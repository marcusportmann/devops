if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
VBOX_VERSION=$(cat /root/.vbox_version)
yum -y install bzip2 wget perl gcc kernel-devel kernel-headers
cd /tmp
mount -o loop /root/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /root/VBoxGuestAdditions_*.iso
fi

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
yum -y install open-vm-tools

cat <<EOT >> /etc/vmware-tools/tools.conf
[guestinfo]
primary-nics=eth*
EOT

fi

