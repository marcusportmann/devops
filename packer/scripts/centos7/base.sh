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

echo "Enabling the EPEL repo"
yum -y install epel-release

echo "Installing additional packages"
yum -y install bzip2 ntp ntpdate python-yaml screen net-tools python2-pip

echo "Installing additional python libraries"
curl -o /tmp/python-netifaces-0.10.4-1.el7.x86_64.rpm https://cbs.centos.org/kojifiles/packages/python-netifaces/0.10.4/1.el7/x86_64/python-netifaces-0.10.4-1.el7.x86_64.rpm
rpm -ihv /tmp/python-netifaces-0.10.4-1.el7.x86_64.rpm

echo "Removing unnecessary packages"
yum -y remove wpa_supplicant
yum -y remove avahi-autoipd
yum -y remove avahi-libs
yum -y remove dnsmasq
yum -y remove gsettings-desktop-schemas
yum -y remove libndp # Library for IPv6 Neighbor Discovery Protocol
yum -y remove libpcap
yum -y remove plymouth-core-libs

echo "Updating all packages"
yum update -y

echo "Enabling NTP"
sudo systemctl enable ntpd.service
sudo ntpdate pool.ntp.org
sudo systemctl start ntpd.service

echo "Stopping and disabling the kdump service"
systemctl stop kdump
systemctl disable kdump

echo "Stopping and disabling the remote-fs.target"
systemctl stop remote-fs.target
systemctl disable remote-fs.target

echo "Disabling GSSAPI for SSH"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

echo "Disabling DNS for SSH"
echo "UseDNS no" >> /etc/ssh/sshd_config

echo "Creating the new initial ramdisk image"
dracut --no-hostonly --force

echo "Install the pyOpenSSL python package"
pip install pyOpenSSL
