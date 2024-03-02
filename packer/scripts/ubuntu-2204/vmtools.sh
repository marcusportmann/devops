if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
VBOX_VERSION=$(cat /root/.vbox_version)
apt-get -y install build-essential dkms linux-headers-$(uname -r)
cd /tmp
mount -o loop /root/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -rf /root/VBoxGuestAdditions_*.iso
fi


if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
apt-get -y install open-vm-tools

cat <<EOT >> /etc/vmware-tools/tools.conf
[guestinfo]
primary-nics=eth*
EOT

fi


if [[ $PACKER_BUILDER_TYPE =~ hyperv ]]; then
mkdir /usr/libexec/hypervkvpd/
ln -s /usr/sbin/hv_get_dhcp_info /usr/libexec/hypervkvpd/hv_get_dhcp_info
ln -s /usr/sbin/hv_get_dns_info /usr/libexec/hypervkvpd/hv_get_dns_info

fi



