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

echo "Install the Zscaler certificate"
cat <<EOT >> /etc/pki/ca-trust/source/anchors/zscaler.crt
-----BEGIN CERTIFICATE-----
MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2Ux
FTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgw
FgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRA
enNjYWxlci5jb20wHhcNMTQxMjE5MDAyNzU1WhcNNDIwNTA2MDAyNzU1WjCBoTEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBK
b3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5j
LjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBw
b3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
qT7STSxZRTgEFFf6doHajSc1vk5jmzmM6BWuOo044EsaTc9eVEV/HjH/1DWzZtcr
fTj+ni205apMTlKBW3UYR+lyLHQ9FoZiDXYXK8poKSV5+Tm0Vls/5Kb8mkhVVqv7
LgYEmvEY7HPY+i1nEGZCa46ZXCOohJ0mBEtB9JVlpDIO+nN0hUMAYYdZ1KZWCMNf
5J/aTZiShsorN2A38iSOhdd+mcRM4iNL3gsLu99XhKnRqKoHeH83lVdfu1XBeoQz
z5V6gA3kbRvhDwoIlTBeMa5l4yRdJAfdpkbFzqiwSgNdhbxTHnYYorDzKfr2rEFM
dsMU0DHdeAZf711+1CunuQIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFLm33UrNww4M
hp1d3+wcBGnFTpjfMIHWBgNVHSMEgc4wgcuAFLm33UrNww4Mhp1d3+wcBGnFTpjf
oYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8G
A1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMM
WnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG
9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDbvpgtibd7kzAMBgNVHRMEBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAw0NdJh8w3NsJu4KHuVZUrmZgIohnTm0j+
RTmYQ9IKA/pvxAcA6K1i/LO+Bt+tCX+C0yxqB8qzuo+4vAzoY5JEBhyhBhf1uK+P
/WVWFZN/+hTgpSbZgzUEnWQG2gOVd24msex+0Sr7hyr9vn6OueH+jj+vCMiAm5+u
kd7lLvJsBu3AO3jGWVLyPkS3i6Gf+rwAp1OsRrv3WnbkYcFf9xjuaf4z0hRCrLN2
xFNjavxrHmsH8jPHVvgc1VD0Opja0l/BRVauTrUaoW6tE+wFG5rEcPGS80jjHK4S
pB5iDj2mUZH1T8lzYtuZy0ZPirxmtsk3135+CKNa2OCAhhFjE0xd
-----END CERTIFICATE-----
EOT
update-ca-trust extract

echo "Enabling the EPEL repo"
yum -y install epel-release

echo "Installing additional packages"
yum -y install bzip2 ntp ntpdate python-yaml screen net-tools python2-pip

echo "Installing additional python libraries"
curl -o /tmp/python-netifaces-0.10.4-1.el7.x86_64.rpm https://cbs.centos.org/kojifiles/packages/python-netifaces/0.10.4/1.el7/x86_64/python-netifaces-0.10.4-1.el7.x86_64.rpm
rpm -ihv /tmp/python-netifaces-0.10.4-1.el7.x86_64.rpm

echo "Removing unnecessary packages"
yum -y remove avahi-autoipd
yum -y remove avahi-libs
yum -y remove dnsmasq
yum -y remove gsettings-desktop-schemas
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

echo 'LANG=en_US.utf-8' >> /etc/environment
echo 'LC_ALL=en_US.utf-8' >> /etc/environment

echo "Configure pip to use the system trusted CA bundle"
cat <<EOT >> /etc/pip.conf
[global]
cert = /etc/pki/tls/certs/ca-bundle.trust.crt
EOT

echo "Upgrade pip"
pip install --upgrade "pip < 21.0"

echo "Install the pyOpenSSL python package"
pip install pyOpenSSL

mkdir /etc/systemd/system/getty@.service.d
cat <<EOT >> /etc/systemd/system/getty@.service.d/noclear.conf
[Service]
TTYVTDisallocate=no
EOT




