# Create the cloud-user user
groupadd --gid 300 cloud-user
useradd --gid 300 --uid 300 --create-home --home-dir=/home/cloud-user cloud-user

# Set the password for the cloud user
echo "cloud" | passwd --stdin cloud-user

# Configure SSH for the cloud-user user
mkdir -m 700 /home/cloud-user/.ssh
touch /home/cloud-user/.ssh/authorized_keys
chmod 600 /home/cloud-user/.ssh/authorized_keys
chown -R cloud-user:cloud-user /home/cloud-user/.ssh

# Enable sudo for the cloud-user user
echo 'cloud-user             ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers.d/cloud-user
echo 'Defaults:cloud-user    env_keep += SSH_AUTH_SOCK' >> /etc/sudoers.d/cloud-user
chmod 0440 /etc/sudoers.d/cloud-user
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers

VIRT=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`
if [[ $VIRT == "VMware" ]]; then

# Install cloud-init
yum -y install cloud-init

# Install the VMware Guest Info provider for cloud-init
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -

# Enable SSH access using passwords for cloud-init
sed -i 's/ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg

# Prevent the password being locked for the cloud-init user
sed -i 's/lock_passwd: true/lock_passwd: false/g' /etc/cloud/cloud.cfg

# Change the cloud-init user
sed -i 's/name: centos/name: cloud-user/g' /etc/cloud/cloud.cfg

# Enable cloud-init
systemctl enable cloud-init

# Reset cloud-init
cloud-init clean --log

fi
