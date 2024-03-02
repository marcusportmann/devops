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
cat <<EOT >> /etc/ssl/certs/zscaler.pem
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
update-ca-certificates

echo "Install the Discovery Group Root CA certificate"
cat <<EOT >> /etc/ssl/certs/DiscoveryGroupRootCA.pem
-----BEGIN CERTIFICATE-----
MIIGSDCCBDCgAwIBAgIQEEQLbZYzbJBGb0iYk6vtEDANBgkqhkiG9w0BAQsFADBl
MRIwEAYKCZImiZPyLGQBGRYCemExEjAQBgoJkiaJk/IsZAEZFgJjbzEZMBcGCgmS
JomT8ixkARkWCWRpc2NvdmVyeTEgMB4GA1UEAxMXRGlzY292ZXJ5IEdyb3VwIFJv
b3QgQ0EwHhcNMTYxMTIxMTcxNzE2WhcNMzYxMTIxMTcxNzE2WjBlMRIwEAYKCZIm
iZPyLGQBGRYCemExEjAQBgoJkiaJk/IsZAEZFgJjbzEZMBcGCgmSJomT8ixkARkW
CWRpc2NvdmVyeTEgMB4GA1UEAxMXRGlzY292ZXJ5IEdyb3VwIFJvb3QgQ0EwggIi
MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC2XxwbKv267LnkRNgoiRZWwASS
nQTW8Ak3a0EpRaYeWJgzReTousXsERyocLVPkO91S8fqe62Om9KDWP1mww147WAx
xaVRHDqqOMFzn2ScMIGxPC8SXJ1D7mWkmfwOJCiFBVUZ4cq2+9Ra9AZbhphbWD9n
f58khJ3M4FxA5KaJK4URRZeBcJLiTPXp4pFc9qU/eGuKD4v+95KRnYNviyLY0+2m
9FJq5V0h5LM9u1SFExX/yrI2Cuaf7goB2B0XvNK0OdWZe7YJL2gj3doDZ6wBtrT0
Z5TWIW1JcOZAmxs2SOcwZRQcbkDTSSgaBxdRac/D9cB4IhojlclxxKDEJLxio4CA
zIhOQOZ7Ri+hTNN+B0whHHWn0rPUYMMEko5tIic0N40007tt2oxnUlHX4UofZygq
4g02dgO6erGnBGKBCvHgq75525qxr52bRuhoY7dAzxtFioWuGySwtTWlyHWy9Amj
su7dOrAj0D5AW+5og6Lst1+6SJPDQiMzMSAHXEWXBwGTYs/T6CyTrKuygAqoGTZL
aTrmtc7haRpgE6hmskPd7gOfeOXIhk2b0gkjCpoPHU59ofzOisyEZxlYVhx0p8DG
2CA0e+eYsnqffNKjg2JQsxp13iNOnEVkBxpoSHCSqb7CeIdUgSbkZFxajzeF62fY
iaytjco17lm/n04S0QIDAQABo4HzMIHwMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBTQCDSy5TA2YWm5aBCPTPyS97HLUDAQBgkrBgEEAYI3
FQEEAwIBADCBngYDVR0gBIGWMIGTMIGQBgRVHSAAMIGHMIGEBggrBgEFBQcCAjB4
HnYAVABoAGkAcwAgAFAASwBJACAAaQBzACAAaQBuAHQAZQBuAGQAZQBkACAAZgBv
AHIAIABpAG4AdABlAHIAbgBhAGwAIABEAGkAcwBjAG8AdgBlAHIAeQAgAEcAcgBv
AHUAcAAgAHUAcwBlACAAbwBuAGwAeQAuMA0GCSqGSIb3DQEBCwUAA4ICAQCKTgW9
wAvdunma3/LoXIpOVnApreOcLMzwDkoMLlk31phRXcWTdzrbfZkRWg2HQoGdKnkJ
w4ehJw31V9UcKRXqEFk+AU7C6Mg/Oq5EAqAbPfo3JqtjPn3qjCvgnUUVV2TbbP+w
J/zPwlwvo3Ex5aMHhsGLdvExQJPZIfmVHBqjdMBxeklA+XpiDH/ENQ5LfPwj4U8i
eSwx5fcApOU5FPCoiDginp+dT/YK/MdyvFkW/BgW02cS9+4t3OC6I+B0irDBU7wl
Jr679kvbY5LzCDWPTt17/5Q+K01SoweWhmaIIBmNbZeE5Kj4pc+8UgIWBlsv+HtL
tXyCgNiC8aAoUeu5RN1ICjy9HXkYl26m/ymIfyLtAqWffI6ZMqlMQkI+A1HOcW1r
tJRjKTXn/mUg5etL7hXOHkhWQRvikiAqtuO9o9A8fhWKe/7ntFk0FqtwAhQCi4h/
cSwxvq8eyJ/463cvsXszrbQXauBE1AWhDeCSACTX/WDv1otxAxoLwzIq0zLShvSR
9wygOP0cb8UX0v4FMREG0q4N8+6mBXA/Oq9WMmSpP44QIGErweBP6PGZ7Qjbx8aU
w3A9jdTf2OPkZMyrhVM58W40c5mNCjeL7exvG0Ad7UC+8Jp0pgdUFSOwU1LzeFOq
ryNr1QltRC35CWEwuaQyVUXpQU8wjo+9OcgrLA==
-----END CERTIFICATE-----
EOT
update-ca-certificates

echo "Installing additional packages"
apt-get -y install python3-pip acl net-tools screen cifs-utils

echo "Updating all packages"
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

# echo "Enabling the ssh-keygen service"
cp /var/tmp/ssh-keygen.service /lib/systemd/system
systemctl enable ssh-keygen

echo "Stopping and disabling the accounts-daemon service"
systemctl stop accounts-daemon
systemctl disable accounts-daemon

echo "Stopping and disabling the remote-fs.target service"
systemctl stop remote-fs.target
systemctl disable remote-fs.target

echo "Installing custom scripts"
cp /var/tmp/configure-network /usr/bin
chmod a+x /usr/bin/configure-network
cp /var/tmp/resize-root-partition /usr/bin
chmod a+x /usr/bin/resize-root-partition

# VIRT=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`
# if [[ $VIRT == "Microsoft HyperV" || $VIRT == "Microsoft Hyper-V" ]]; then
# 	apt-get -y install linux-tools-$(uname -r) linux-cloud-tools-$(uname -r) linux-cloud-tools-common linux-azure
# fi

echo "Disabling GSSAPI for SSH"
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

echo "Disabling DNS for SSH"
echo "UseDNS no" >> /etc/ssh/sshd_config

mkdir /etc/systemd/system/getty@.service.d
cat <<EOT >> /etc/systemd/system/getty@.service.d/noclear.conf
[Service]
TTYVTDisallocate=no
EOT


# We need to disable SELinux when running under Hyper-V to support the ansible_local provisioner
if [[ $PACKER_BUILDER_TYPE =~ hyperv ]]; then
cat <<EOT > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOT

fi


# Disable floppy
echo "blacklist floppy" > /etc/modprobe.d/blacklist-floppy.conf
rmmod floppy
dpkg-reconfigure initramfs-tools










