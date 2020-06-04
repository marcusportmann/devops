#!/bin/bash -eux

echo "Preventing users mounting USB storage"
echo "install usb-storage /bin/false" > /etc/modprobe.d/usb-storage.conf

echo "Securing root login"
echo "tty1" > /etc/securetty
chmod 700 /root

# Prune Idle Users
echo "Ensuring idle users will be removed after 15 minutes"
echo "readonly TMOUT=900" >> /etc/profile.d/os-security.sh
echo "readonly HISTFILE" >> /etc/profile.d/os-security.sh
chmod +x /etc/profile.d/os-security.sh

# Secure Cron and AT
echo "Locking down Cron"
touch /etc/cron.allow
chmod 600 /etc/cron.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /tmp/cron.deny
rm -f /etc/cron.deny
mv /tmp/cron.deny /etc/cron.deny
echo "Locking down AT"
touch /etc/at.allow
chmod 600 /etc/at.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /tmp/at.deny
rm -f /etc/at.deny
mv /tmp/at.deny /etc/at.deny

echo "Denying all TCP wrappers"
echo "ALL:ALL" >> /etc/hosts.deny
echo "sshd:ALL" >> /etc/hosts.allow

echo "Disabling uncommon protocols"
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf

echo "Installing additional packages"
apt-get -y install python3-pip

echo "Removing unnecessary packages"

# echo "Updating all packages"
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

echo "Enabling the ssh-keygen service"
cp /tmp/ssh-keygen.service /lib/systemd/system
systemctl enable ssh-keygen

echo "Stopping and disabling the accounts-daemon service"
systemctl stop accounts-daemon
systemctl disable accounts-daemon

echo "Stopping and disabling the remote-fs.target service"
systemctl stop remote-fs.target
systemctl disable remote-fs.target

echo "Installing custom scripts"
cp /tmp/configure-network /usr/bin
chmod a+x /usr/bin/configure-network
cp /tmp/resize-root-partition /usr/bin
chmod a+x /usr/bin/resize-root-partition

VIRT=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`
if [[ $VIRT == "Microsoft HyperV" || $VIRT == "Microsoft Hyper-V" ]]; then
	apt-get -y install linux-tools-$(uname -r) linux-cloud-tools-$(uname -r) linux-cloud-tools-common linux-azure
fi

echo "Disabling GSSAPI for SSH"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

echo "Disabling DNS for SSH"
echo "UseDNS no" >> /etc/ssh/sshd_config

echo "Install the pyOpenSSL python package"
pip3 install pyOpenSSL





